import 'package:drift/drift.dart';

import 'package:reminiscence/features/database/models/message.dart';
import 'package:reminiscence/features/database/models/attachment_type.dart';

class Attachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text().references(Messages, #id)();
  TextColumn get type => textEnum<AttachmentType>()();
  TextColumn get uri => text()();
}