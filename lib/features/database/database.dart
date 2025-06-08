import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:reminiscence/features/database/daos/chat_dao.dart';

import 'package:reminiscence/features/database/models/chat.dart';
import 'package:reminiscence/features/database/models/participant.dart';
import 'package:reminiscence/features/database/models/message.dart';
import 'package:reminiscence/features/database/models/attachment.dart';
import 'package:reminiscence/features/database/models/attachment_type.dart';
import 'package:reminiscence/features/database/sqlcipher.dart';

part 'database.g.dart';

// dart run build_runner build --delete-conflicting-outputs

String escapeString(String source) {
  return source.replaceAll('\'', '\'\'');
}

@DriftDatabase(
  tables: [Chats, Participants, Messages, Attachments],
  daos: [ChatDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({
    QueryExecutor? executor,
    required String dbPath,
    String? password,
    RootIsolateToken? token,
  }) : super(executor ?? _openConnection(dbPath, password, token));

  @override
  int get schemaVersion => 1;

  // Custom _openConnection implementation
  static QueryExecutor _openConnection(
    String dbPath,
    String? password,
    RootIsolateToken? token,
  ) {
    token ??= RootIsolateToken.instance;

    return NativeDatabase.createInBackground(
      File(dbPath),
      isolateSetup: () async {
        if (token != null) {
          BackgroundIsolateBinaryMessenger.ensureInitialized(token);
        }
        await setupSqlCipher();
      },
      setup: (rawDb) {
        if (password != null) {
          rawDb.execute("PRAGMA key = '${escapeString(password)}';");
        }
        rawDb.config.doubleQuotedStringLiterals = false;
      },
    );
  }
}
