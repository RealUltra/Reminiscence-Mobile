import 'package:drift/drift.dart';

import 'package:reminiscence/features/database/tables/chats.dart';

class Participants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chatId => integer().references(Chats, #id)();
  TextColumn get name => text()();
}
