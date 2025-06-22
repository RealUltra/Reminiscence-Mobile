import 'package:drift/drift.dart';
import 'package:reminiscence/features/data_storage/pinned_messages.dart';
import 'package:reminiscence/features/data_storage/system_messages.dart';

import 'package:reminiscence/features/database/database.dart';
import 'package:reminiscence/features/database/dtos/attachment_dto.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/features/database/models/attachment.dart';
import 'package:reminiscence/features/database/models/message.dart';

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

  Future<List<int>> getMessageTimestamps(int chatId) async {
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
              sent_at

            FROM
              messages

            WHERE
              chat_id = ?
              AND no_emojis_content NOT IN ($placeholders)

            ORDER BY
              sent_at DESC
          """, variables: variables).get();

    return rows.map((r) => r.read<int>("sent_at")).toList();
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
