import 'package:drift/drift.dart';
import 'package:reminiscence/features/data_storage/pinned_messages.dart';
import 'package:reminiscence/features/data_storage/system_messages.dart';

import 'package:reminiscence/features/database/database.dart';
import 'package:reminiscence/features/database/dtos/attachment_dto.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/features/database/models/attachment.dart';
import 'package:reminiscence/features/database/models/message.dart';
import 'package:reminiscence/ui/pages/search/filter.dart';
import 'package:reminiscence/ui/pages/search/filter_type.dart';

part 'message_dao.g.dart';

@DriftAccessor(tables: [Messages, Attachments])
class MessageDao extends DatabaseAccessor<AppDatabase> with _$MessageDaoMixin {
  MessageDao(super.db);

  Future<List<String>> getMessageIds(int chatId) async {
    final systemMessages = await getSystemMessages();

    final placeholders = List.generate(
      systemMessages.length,
      (i) => '?',
    ).join(', ');

    final variables = [
      Variable.withInt(chatId),
      ...systemMessages.map((msg) => Variable.withString(msg)),
    ];

    final rows =
        await customSelect("""
            SELECT
              id

            FROM
              messages

            WHERE
              chat_id = ?
              AND no_emojis_content NOT IN ($placeholders)

            ORDER BY
              sent_at DESC
          """, variables: variables).get();

    return rows.map((r) => r.read<String>("id")).toList();
  }

  Future<List<MessageDto>> getMessages(List<String> messageIds) async {
    final placeholders = List.filled(messageIds.length, '?').join(',');

    final variables = messageIds.map((id) => Variable.withString(id)).toList();

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
              m.id IN ($placeholders)

            ORDER BY
              m.sent_at DESC
          """, variables: variables).get();

    return _getMessageDtos(rows);
  }

  Future<List<MessageDto>> getPinned(int chatId) async {
    final allPinnedMessages = await getPinnedMessages();

    final placeholders = List.generate(
      allPinnedMessages.length,
      (i) => '?',
    ).join(', ');

    final variables = [
      ...allPinnedMessages.map((id) => Variable.withString(id)),
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

  Future<List<int>> getMessageTimestamps(
    int chatId, {
    String? senderName,
  }) async {
    final systemMessages = await getSystemMessages();

    final placeholders = List.generate(
      systemMessages.length,
      (i) => '?',
    ).join(', ');

    final variables = [
      Variable.withInt(chatId),
      ...systemMessages.map((msg) => Variable.withString(msg)),
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

  Future<List<MessageDto>> searchByFilters(
    int chatId,
    List<Filter> filters,
  ) async {
    final whereClauses = ["m.chat_id = ?"];
    final variables = <Variable>[Variable.withInt(chatId)];

    for (final filter in filters) {
      if (filter.type == FilterType.query) {
        whereClauses.add("m.content LIKE ?");
        variables.add(Variable.withString("%${filter.query!}%"));
        //
      } else if (filter.type == FilterType.sender) {
        whereClauses.add("m.sender_name = ?");
        variables.add(Variable.withString(filter.senderName!));
        //
      } else if (filter.type == FilterType.attachment) {
        whereClauses.add("a.type = ?");
        variables.add(Variable.withString(filter.attachmentType!.name));
        //
      } else if (filter.type == FilterType.sentBefore) {
        whereClauses.add("m.sent_at < ?");
        variables.add(Variable.withInt(filter.date!.millisecondsSinceEpoch));
        //
      } else if (filter.type == FilterType.sentOn) {
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
        //
      } else {
        whereClauses.add("m.sent_at > ?");
        variables.add(Variable.withInt(filter.date!.millisecondsSinceEpoch));
        //
      }
    }

    final whereSql = whereClauses.join(" AND ");

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

            WHERE $whereSql
          """, variables: variables).get();

    return _getMessageDtos(rows);
  }

  List<MessageDto> _getMessageDtos(List<QueryRow> rows) {
    final messageDtos = <String, MessageDto>{};

    for (final row in rows) {
      final id = row.read<String>("id");
      final chatId = row.read<int>("chat_id");
      final index = row.read<int>("index");
      final rawData = row.read<String>("raw_data");
      final sentAt = row.read<int>("sent_at");
      final senderName = row.read<String>("sender_name");
      final content = row.read<String>("content");
      final noEmojisContent = row.read<String>("no_emojis_content");

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
}
