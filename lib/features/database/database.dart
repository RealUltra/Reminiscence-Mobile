import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';

import 'package:reminiscence/features/database/models/chat.dart';
import 'package:reminiscence/features/database/models/participant.dart';
import 'package:reminiscence/features/database/models/message.dart';
import 'package:reminiscence/features/database/models/attachment.dart';
import 'package:reminiscence/features/database/models/attachment_type.dart';
import 'package:reminiscence/features/database/sqlcipher.dart';

part 'database.g.dart';

// dart run build_runner build --delete-conflicting-outputs

@DriftDatabase(tables: [Chats, Participants, Messages, Attachments])
class AppDatabase extends _$AppDatabase {
  AppDatabase({
    QueryExecutor? executor,
    required String dbPath,
    String? password,
    RootIsolateToken? token,
  }) : super(executor ?? _openConnection(dbPath, password, token));

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection(
    String dbPath,
    String? password,
    RootIsolateToken? token,
  ) {
    return NativeDatabase.createInBackground(
      File(dbPath),
      isolateSetup: () async {
        BackgroundIsolateBinaryMessenger.ensureInitialized(
          token ?? RootIsolateToken.instance!,
        );
        await setupSqlCipher();
      },
      setup: (rawDb) {
        if (password != null) {
          rawDb.execute("PRAGMA key = '$password'");
        }
        rawDb.config.doubleQuotedStringLiterals = false;
      },
    );
  }
}
