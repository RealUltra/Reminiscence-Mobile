import 'package:drift/drift.dart';
import 'package:reminiscence/features/data_storage/system_messages.dart';

import 'package:reminiscence/features/database/database.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/features/database/models/chat.dart';
import 'package:reminiscence/features/database/models/message.dart';

part 'chat_dao.g.dart';

@DriftAccessor(tables: [Chats, Messages])
class ChatDao extends DatabaseAccessor<AppDatabase> with _$ChatDaoMixin {
  ChatDao(super.db);

  Future<List<ChatDto>> getChatDtos() async {
    final systemMessages = await getSystemMessages();
    final placeholders = List.filled(systemMessages.length, "?").join(",");

    final variables =
        systemMessages.map((msg) => Variable.withString(msg)).toList();

    final rows =
        await customSelect("""
          SELECT 
            c.id, 
            c.title,
            c.user_name,
            COUNT(m.id) AS message_count,
            MAX(m.sent_at) AS last_message_sent_at
          FROM 
            chats c
          LEFT JOIN
            messages m
            ON m.chat_id = c.id
            AND m.no_emojis_content NOT IN ($placeholders)
          GROUP BY
            c.id;
          """, variables: variables).get();

    final chatDtos =
        rows.map((row) {
          final id = row.read<int>('id');
          final title = row.read<String>('title');
          final userName = row.read<String?>('user_name');
          final messageCount = row.read<int>('message_count');
          final lastMessageTimestamp = row.read<int>('last_message_sent_at');

          return ChatDto(
            id: id,
            title: title,
            userName: userName,
            messageCount: messageCount,
            lastMessageSentAt: DateTime.fromMillisecondsSinceEpoch(
              lastMessageTimestamp,
            ),
          );
        }).toList();

    return chatDtos;
  }
}
