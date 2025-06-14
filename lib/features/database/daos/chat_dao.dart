import 'package:drift/drift.dart';

import 'package:reminiscence/features/database/database.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/features/database/models/chat.dart';
import 'package:reminiscence/features/database/models/message.dart';

part 'chat_dao.g.dart';

@DriftAccessor(tables: [Chats, Messages])
class ChatDao extends DatabaseAccessor<AppDatabase> with _$ChatDaoMixin {
  ChatDao(super.db);

  Future<List<ChatDto>> getChatDtos() async {
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
          GROUP BY
            c.id;
          """).get();

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
