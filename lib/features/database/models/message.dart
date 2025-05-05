import 'package:floor/floor.dart';

import 'package:reminiscence/features/database/models/chat.dart';

@Entity(
  tableName: 'messages',
  foreignKeys: [
    ForeignKey(
      childColumns: ['chat_id'],
      parentColumns: ['id'],
      entity: Chat,
      onDelete: ForeignKeyAction.cascade
    )
  ]
)
class Message {
  @PrimaryKey()
  final String id;

  @ColumnInfo(name: 'chat_id')
  final int chatId;

  @ColumnInfo(name: 'raw_data')
  final String rawData;

  @ColumnInfo(name: "sent_at")
  final int sentAt;

  @ColumnInfo(name: "sender_name")
  final String senderName;

  final String content;

  Message({
    required this.id,
    required this.chatId,
    required this.rawData,
    required this.sentAt,
    required this.senderName,
    required this.content
  });

}