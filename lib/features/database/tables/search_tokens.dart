import 'package:drift/drift.dart';

import 'package:reminiscence/features/database/tables/messages.dart';

class SearchTokens extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text().references(Messages, #id)();
  TextColumn get value => text()();
}
