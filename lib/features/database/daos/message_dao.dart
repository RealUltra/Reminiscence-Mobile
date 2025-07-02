import 'package:drift/drift.dart';
import 'package:reminiscence/features/data_storage/pinned_messages.dart';
import 'package:reminiscence/features/data_storage/system_messages.dart';
import 'package:reminiscence/features/database/daos/message_column.dart';

import 'package:reminiscence/features/database/database.dart';
import 'package:reminiscence/features/database/dtos/attachment_dto.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/features/database/tables/attachments.dart';
import 'package:reminiscence/features/database/tables/messages.dart';
import 'package:reminiscence/features/tokenizer/tokenizer.dart';
import 'package:reminiscence/ui/pages/search/filter.dart';
import 'package:reminiscence/ui/pages/search/filter_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'message_dao.g.dart';

@DriftAccessor(tables: [Messages, Attachments])
class MessageDao extends DatabaseAccessor<AppDatabase> with _$MessageDaoMixin {
  MessageDao(super.db);

  // All messages, but partial columns. Used in message reader to get only the timestamps and ids.
  Future<List<MessageDto>> getAllMessages(
    int chatId, {
    List<MessageColumn> columns = allColumns,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final systemMessages = getSystemMessages(prefs);
    final systemPlaceholders = _getPlaceholders(systemMessages.length);

    final columnNames = getColumnNames(columns);
    final selectSql = columnNames.join(", ");

    final variables = [
      Variable.withInt(chatId),
      ...systemMessages.map(Variable.withString),
    ];

    final joinAttachmentsSql =
        includesAttachment(columns)
            ? "LEFT JOIN attachments a ON a.message_id = m.id"
            : "";

    final query = """
        SELECT 
          $selectSql

        FROM 
          messages m

        $joinAttachmentsSql

        WHERE
          m.chat_id = ?
          AND m.no_emojis_content NOT IN ($systemPlaceholders)

        ORDER BY
          m.sent_at DESC
      """;

    final rows = await customSelect(query, variables: variables).get();

    return _getMessageDtos(rows);
  }

  // Used to lazy load messages by the message reader.
  Future<List<MessageDto>> getMessages(
    int chatId,
    int startTimestamp,
    int limit,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final systemMessages = getSystemMessages(prefs);
    final placeholders = _getPlaceholders(systemMessages.length);

    final variables = [
      Variable.withInt(chatId),
      ...systemMessages.map(Variable.withString),
      Variable.withInt(startTimestamp),
      Variable.withInt(limit),
    ];

    final query = """
        SELECT
          m.id,
          m.chat_id,
          m."index",
          m.raw_data,
          m.sent_at,
          m.sender_name,
          m.content,
          m.no_emojis_content,

          a.id as attachment_id,
          a.type as attachment_type,
          a.uri as attachment_uri

        FROM
          messages m

        LEFT JOIN
          attachments a
          ON a.message_id = m.id

        WHERE
          m.chat_id = ?
          AND m.no_emojis_content NOT IN ($placeholders)
          AND m.sent_at <= ?

        ORDER BY 
          m.sent_at DESC

        LIMIT ?
      """;

    final rows = await customSelect(query, variables: variables).get();

    return _getMessageDtos(rows);
  }

  // Used for retrieving pinned messages
  Future<List<MessageDto>> getPinned(int chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final allPinnedMessages = getPinnedMessages(prefs);
    final placeholders = _getPlaceholders(allPinnedMessages.length);

    final variables = [
      ...allPinnedMessages.map(Variable.withString),
      Variable.withInt(chatId),
    ];

    final rows =
        await customSelect("""
            SELECT
              m.id,
              m.chat_id,
              m."index",
              m.raw_data,
              m.sent_at,
              m.sender_name,
              m.content,
              m.no_emojis_content,

              a.id as attachment_id,
              a.type as attachment_type,
              a.uri as attachment_uri

            FROM
              messages m

            LEFT JOIN
              attachments a
              ON a.message_id = m.id

            WHERE
              m.id IN ($placeholders) AND
              m.chat_id = ?
          """, variables: variables).get();

    return _getMessageDtos(rows);
  }

  // Used for getting all the message timestamps from a chat and from a particular sender. Used in the graph.
  Future<List<int>> getMessageTimestamps(
    int chatId, {
    String? senderName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final systemMessages = getSystemMessages(prefs);
    final placeholders = _getPlaceholders(systemMessages.length);

    final variables = [
      Variable.withInt(chatId),
      ...systemMessages.map(Variable.withString),
    ];

    final includeSender = senderName != null;

    if (includeSender) {
      variables.add(Variable.withString(senderName));
    }

    final rows =
        await customSelect("""
        SELECT
          sent_at

        FROM
          messages

        WHERE
          chat_id = ?
          AND no_emojis_content NOT IN ($placeholders)
          ${includeSender ? 'AND sender_name = ?' : ''}

        ORDER BY
          sent_at DESC
      """, variables: variables).get();

    return rows.map((r) => r.read<int>("sent_at")).toList();
  }

  // Used for searching wiht custom filters.
  Future<List<MessageDto>> searchByFilters(
    int chatId,
    List<Filter> filters,
  ) async {
    final whereClauses = ["m.chat_id = ?"];
    final variables = <Variable>[Variable.withInt(chatId)];

    for (final filter in filters) {
      if (filter.type == FilterType.query) {
        final tokens = tokenize(filter.query!);
        final placeholders = _getPlaceholders(tokens.length);

        whereClauses.add("st.value IN ($placeholders)");
        variables.addAll(tokens.map(Variable.withString));
      }

      if (filter.type == FilterType.sender) {
        whereClauses.add("m.sender_name = ?");
        variables.add(Variable.withString(filter.senderName!));
      }

      if (filter.type == FilterType.attachment) {
        whereClauses.add("a.type = ?");
        variables.add(Variable.withString(filter.attachmentType!.name));
      }

      if (filter.type == FilterType.sentBefore) {
        whereClauses.add("m.sent_at < ?");
        variables.add(Variable.withInt(filter.date!.millisecondsSinceEpoch));
      }

      if (filter.type == FilterType.sentOn) {
        final startOfDay = DateTime(
          filter.date!.year,
          filter.date!.month,
          filter.date!.day,
        );
        final endOfDay = startOfDay.add(const Duration(days: 1));

        whereClauses.add("m.sent_at >= ? AND m.sent_at < ?");

        variables.addAll([
          Variable.withInt(startOfDay.millisecondsSinceEpoch),
          Variable.withInt(endOfDay.millisecondsSinceEpoch),
        ]);
      }

      if (filter.type == FilterType.sentAfter) {
        whereClauses.add("m.sent_at > ?");
        variables.add(Variable.withInt(filter.date!.millisecondsSinceEpoch));
      }
    }

    final whereSql = whereClauses.join(" AND ");

    final joinTokensClause =
        whereSql.contains("st.value")
            ? "LEFT JOIN search_tokens st ON st.message_id = m.id"
            : "";

    final rows =
        await customSelect("""
            SELECT
              m.id,
              m.chat_id,
              m."index",
              m.raw_data,
              m.sent_at,
              m.sender_name,
              m.content,
              m.no_emojis_content,

              a.id as attachment_id,
              a.type as attachment_type,
              a.uri as attachment_uri

            FROM
              messages m

            LEFT JOIN
              attachments a
              ON a.message_id = m.id

            $joinTokensClause

            WHERE $whereSql
          """, variables: variables).get();

    return _getMessageDtos(rows);
  }

  // Used for converting the rows into message dtos.
  List<MessageDto> _getMessageDtos(List<QueryRow> rows) {
    final messageDtos = <String, MessageDto>{};

    for (final row in rows) {
      final id = row.read<String?>("id") ?? "";
      final chatId = row.read<int?>("chat_id") ?? -1;
      final index = row.read<int?>("index") ?? -1;
      final rawData = row.read<String?>("raw_data") ?? "";
      final sentAt = row.read<int?>("sent_at") ?? -1;
      final senderName = row.read<String?>("sender_name") ?? "";
      final content = row.read<String?>("content") ?? "";
      final noEmojisContent = row.read<String?>("no_emojis_content") ?? "";

      final attachmentId = row.read<int?>("attachment_id");
      final attachmentType = row.read<String?>("attachment_type");
      final attachmentUri = row.read<String?>("attachment_uri");

      if (!messageDtos.containsKey(id)) {
        messageDtos[id] = MessageDto(
          id: id,
          chatId: chatId,
          index: index,
          rawData: rawData,
          sentAt: sentAt,
          senderName: senderName,
          content: content,
          noEmojisContent: noEmojisContent,
          attachments: [],
        );
      }

      if (attachmentId != null &&
          attachmentType != null &&
          attachmentUri != null) {
        messageDtos[id]!.attachments.add(
          AttachmentDto(
            id: attachmentId,
            messageId: id,
            type: attachmentType,
            uri: attachmentUri,
          ),
        );
      }
    }

    return messageDtos.values.toList();
  }

  // Used for creating a placeholder string of a certain length.
  String _getPlaceholders(int length) {
    return List.generate(length, (i) => '?').join(', ');
  }
}
