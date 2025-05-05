import 'package:floor/floor.dart';

import 'package:reminiscence/features/database/models/message.dart';

@Entity(
  tableName: 'attachments',
  foreignKeys: [
    ForeignKey(
      childColumns: ['message_id'],
      parentColumns: ['id'],
      entity: Message,
      onDelete: ForeignKeyAction.cascade
    )
  ]
)
class Attachment {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  
  @ColumnInfo(name: 'message_id')
  final String messageId;

  final String type; // Holds one of "photo", "video", "audio", "link", "file"

  final String? link;

  Attachment({
    this.id,
    required this.messageId,
    required this.type,
    this.link
  });

}