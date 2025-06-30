import 'package:drift/drift.dart';

import 'package:reminiscence/features/database/tables/messages.dart';
import 'package:reminiscence/features/database/tables/attachment_type.dart';

@TableIndex(name: 'idx_attachments_message_id', columns: {#messageId})
@TableIndex(name: 'idx_attachments_type', columns: {#type})
class Attachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text().references(Messages, #id)();
  TextColumn get type => textEnum<AttachmentType>()();
  TextColumn get uri => text()();
}
