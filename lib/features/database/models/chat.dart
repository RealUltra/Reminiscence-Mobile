import 'package:drift/drift.dart';

class Chats extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get userName => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
