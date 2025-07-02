import 'package:drift/drift.dart';

import 'package:reminiscence/features/database/tables/chats.dart';

@TableIndex(name: 'idx_messages_id', columns: {#id})
@TableIndex(name: 'idx_messages_chat_id', columns: {#chatId})
@TableIndex(name: 'idx_messages_sender_name', columns: {#senderName})
@TableIndex.sql('''
  CREATE INDEX idx_messages_chat_time_desc ON messages (chat_id, sent_at DESC);
''')
class Messages extends Table {
  TextColumn get id => text()();
  IntColumn get chatId => integer().references(Chats, #id)();
  TextColumn get rawData => text()();
  IntColumn get sentAt => integer()();
  TextColumn get senderName => text()();
  TextColumn get content => text()();
  TextColumn get noEmojisContent => text()();
  TextColumn get searchContent => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
