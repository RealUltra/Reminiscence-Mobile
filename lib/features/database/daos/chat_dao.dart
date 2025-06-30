import 'package:drift/drift.dart';
import 'package:reminiscence/features/data_storage/system_messages.dart';

import 'package:reminiscence/features/database/database.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/features/database/tables/chats.dart';
import 'package:reminiscence/features/database/tables/messages.dart';

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
            MAX(m.sent_at) AS last_message_sent_at,
            p.name as participant_name

          FROM 
            chats c

          LEFT JOIN
            messages m
            ON m.chat_id = c.id
            AND m.no_emojis_content NOT IN ($placeholders)

          LEFT JOIN
            participants p
            ON p.chat_id = c.id

          GROUP BY
            c.id, c.title, c.user_name, p.name;
          """, variables: variables).get();

    return _getChatDtos(rows);
  }

  List<ChatDto> _getChatDtos(List<QueryRow> rows) {
    final chatDtos = <int, ChatDto>{};

    for (final row in rows) {
      final id = row.read<int>('id');
      final title = row.read<String>('title');
      final userName = row.read<String?>('user_name');
      final messageCount = row.read<int>('message_count');
      final lastMessageTimestamp = row.read<int>('last_message_sent_at');

      final participantName = row.read<String?>("participant_name");

      if (!chatDtos.containsKey(id)) {
        chatDtos[id] = ChatDto(
          id: id,
          title: title,
          userName: userName,
          messageCount: messageCount,
          lastMessageSentAt: DateTime.fromMillisecondsSinceEpoch(
            lastMessageTimestamp,
          ),
          participants: [],
        );
      }

      if (participantName != null) {
        chatDtos[id]!.participants.add(participantName);
      }
    }

    return chatDtos.values.toList();
  }
}
