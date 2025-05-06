import 'package:drift/drift.dart';

class Chats extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}