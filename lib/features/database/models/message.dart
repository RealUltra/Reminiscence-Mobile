import 'package:drift/drift.dart';

import 'package:reminiscence/features/database/models/chat.dart';

class Messages extends Table {
  TextColumn get id => text()();
  IntColumn get chatId => integer().references(Chats, #id)();
  TextColumn get rawData => text()();
  IntColumn get sentAt => integer()();
  TextColumn get senderName => text()();
  TextColumn get content => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}