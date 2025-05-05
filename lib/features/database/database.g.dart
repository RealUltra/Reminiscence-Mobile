// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ChatDao? _chatDaoInstance;

  ParticipantDao? _participantDaoInstance;

  MessageDao? _messageDaoInstance;

  AttachmentDao? _attachmentDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `chats` (`id` INTEGER NOT NULL, `title` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `participants` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `chat_id` INTEGER NOT NULL, `name` TEXT NOT NULL, FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `messages` (`id` TEXT NOT NULL, `chat_id` INTEGER NOT NULL, `raw_data` TEXT NOT NULL, `sent_at` INTEGER NOT NULL, `sender_name` TEXT NOT NULL, `content` TEXT NOT NULL, FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `attachments` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `message_id` TEXT NOT NULL, `type` TEXT NOT NULL, `link` TEXT, FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ChatDao get chatDao {
    return _chatDaoInstance ??= _$ChatDao(database, changeListener);
  }

  @override
  ParticipantDao get participantDao {
    return _participantDaoInstance ??=
        _$ParticipantDao(database, changeListener);
  }

  @override
  MessageDao get messageDao {
    return _messageDaoInstance ??= _$MessageDao(database, changeListener);
  }

  @override
  AttachmentDao get attachmentDao {
    return _attachmentDaoInstance ??= _$AttachmentDao(database, changeListener);
  }
}

class _$ChatDao extends ChatDao {
  _$ChatDao(
    this.database,
    this.changeListener,
  ) : _chatInsertionAdapter = InsertionAdapter(
            database,
            'chats',
            (Chat item) =>
                <String, Object?>{'id': item.id, 'title': item.title});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final InsertionAdapter<Chat> _chatInsertionAdapter;

  @override
  Future<int> insertItem(Chat item) {
    return _chatInsertionAdapter.insertAndReturnId(
        item, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertItems(List<Chat> items) {
    return _chatInsertionAdapter.insertListAndReturnIds(
        items, OnConflictStrategy.replace);
  }
}

class _$ParticipantDao extends ParticipantDao {
  _$ParticipantDao(
    this.database,
    this.changeListener,
  ) : _participantInsertionAdapter = InsertionAdapter(
            database,
            'participants',
            (Participant item) => <String, Object?>{
                  'id': item.id,
                  'chat_id': item.chatId,
                  'name': item.name
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final InsertionAdapter<Participant> _participantInsertionAdapter;

  @override
  Future<int> insertItem(Participant item) {
    return _participantInsertionAdapter.insertAndReturnId(
        item, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertItems(List<Participant> items) {
    return _participantInsertionAdapter.insertListAndReturnIds(
        items, OnConflictStrategy.replace);
  }
}

class _$MessageDao extends MessageDao {
  _$MessageDao(
    this.database,
    this.changeListener,
  ) : _messageInsertionAdapter = InsertionAdapter(
            database,
            'messages',
            (Message item) => <String, Object?>{
                  'id': item.id,
                  'chat_id': item.chatId,
                  'raw_data': item.rawData,
                  'sent_at': item.sentAt,
                  'sender_name': item.senderName,
                  'content': item.content
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final InsertionAdapter<Message> _messageInsertionAdapter;

  @override
  Future<int> insertItem(Message item) {
    return _messageInsertionAdapter.insertAndReturnId(
        item, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertItems(List<Message> items) {
    return _messageInsertionAdapter.insertListAndReturnIds(
        items, OnConflictStrategy.replace);
  }
}

class _$AttachmentDao extends AttachmentDao {
  _$AttachmentDao(
    this.database,
    this.changeListener,
  ) : _attachmentInsertionAdapter = InsertionAdapter(
            database,
            'attachments',
            (Attachment item) => <String, Object?>{
                  'id': item.id,
                  'message_id': item.messageId,
                  'type': item.type,
                  'link': item.link
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final InsertionAdapter<Attachment> _attachmentInsertionAdapter;

  @override
  Future<int> insertItem(Attachment item) {
    return _attachmentInsertionAdapter.insertAndReturnId(
        item, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertItems(List<Attachment> items) {
    return _attachmentInsertionAdapter.insertListAndReturnIds(
        items, OnConflictStrategy.replace);
  }
}
