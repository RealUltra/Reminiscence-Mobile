import 'package:floor/floor.dart';

import 'package:reminiscence/features/database/models/chat.dart';

@Entity(
  tableName: 'participants',
  foreignKeys: [
    ForeignKey(
      childColumns: ['chat_id'],
      parentColumns: ['id'],
      entity: Chat,
      onDelete: ForeignKeyAction.cascade
    )
  ]
)
class Participant {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'chat_id')
  final int chatId;

  final String name;

  Participant({
    this.id,
    required this.chatId,
    required this.name
  });
}