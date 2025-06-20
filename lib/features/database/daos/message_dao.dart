import 'package:drift/drift.dart';
import 'package:reminiscence/features/data_storage/data_storage.dart';

import 'package:reminiscence/features/database/database.dart';
import 'package:reminiscence/features/database/dtos/attachment_dto.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/features/database/models/attachment.dart';
import 'package:reminiscence/features/database/models/message.dart';

part 'message_dao.g.dart';

@DriftAccessor(tables: [Messages, Attachments])
class MessageDao extends DatabaseAccessor<AppDatabase> with _$MessageDaoMixin {
  MessageDao(super.db);

  Future<List<MessageDto>> getMessages(
    int chatId,
    int startIndex,
    int length,
  ) async {
    final rows =
        await customSelect(
          """
            SELECT
              m.id,
              m.chat_id,
              m."index",
              m.raw_data,
              m.sent_at,
              m.sender_name,
              m.content,
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
              AND m."index" >= ?
              AND m."index" < ?

            LIMIT
              ?
          """,
          variables: [
            Variable.withInt(chatId),
            Variable.withInt(startIndex),
            Variable.withInt(startIndex + length),
            Variable.withInt(length),
          ],
        ).get();

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
