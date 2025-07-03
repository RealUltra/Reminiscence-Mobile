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

    final variables = [
      ...systemMessages.map((msg) => Variable.withString(msg)),
      ...systemMessages.map((msg) => Variable.withString(msg)),
    ];

    final query = """
      SELECT 
        c.id, 
        c.title,
        c.user_name,

        (
          SELECT 
            COUNT(*)
          
          FROM 
            messages m
            
          WHERE 
            m.chat_id = c.id
            AND m.no_emojis_content NOT IN ($placeholders)
          ) AS message_count,
          
          (
            SELECT 
              sent_at

            FROM 
              messages m
            
            WHERE 
              m.chat_id = c.id
              AND m.no_emojis_content NOT IN ($placeholders)

            ORDER BY
              sent_at DESC
            
            LIMIT 1
          ) AS last_message_sent_at,

        GROUP_CONCAT(p.name, ', ') AS participant_names

      FROM 
        chats c

      LEFT JOIN
        participants p
        ON p.chat_id = c.id

      GROUP BY
        c.id
    """;

    final rows = await customSelect(query, variables: variables).get();

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

      final participantNames =
          row
              .read<String>("participant_names")
              .split(", ")
              .where((x) => x.trim().isNotEmpty)
              .toList();

      if (!chatDtos.containsKey(id)) {
        chatDtos[id] = ChatDto(
          id: id,
          title: title,
          userName: userName,
          messageCount: messageCount,
          lastMessageSentAt: DateTime.fromMillisecondsSinceEpoch(
            lastMessageTimestamp,
          ),
          participants: participantNames,
        );
      }
    }

    return chatDtos.values.toList();
  }
}
