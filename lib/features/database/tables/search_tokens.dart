import 'package:drift/drift.dart';

import 'package:reminiscence/features/database/tables/messages.dart';

@TableIndex(name: 'idx_search_tokens_message_id', columns: {#messageId})
class SearchTokens extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text().references(Messages, #id)();
  TextColumn get value => text()();
}
