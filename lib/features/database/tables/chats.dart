import 'package:drift/drift.dart';

@TableIndex(name: 'idx_chats_id', columns: {#id})
class Chats extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get userName => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
