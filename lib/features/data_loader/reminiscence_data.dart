import 'dart:io';
import 'dart:ui';

import 'package:reminiscence/features/database/database.dart';

class ReminiscenceData {
  final String dbPath;
  final String? password;
  final List<int> nonce;
  final Directory mediaDir;
  AppDatabase? _db;

  ReminiscenceData({
    required this.dbPath,
    required this.password,
    required this.nonce,
    required this.mediaDir,
  });

  static ReminiscenceData fromMap(Map<String, dynamic> data) {
    return ReminiscenceData(
      dbPath: data["dbPath"],
      password: data["password"],
      nonce: data["nonce"],
      mediaDir: Directory(data["mediaDir"]),
    );
  }

  void loadDatabase({RootIsolateToken? token}) {
    _db ??= AppDatabase(dbPath: dbPath, password: password, token: token);
  }

  Future<void> closeDatabase({RootIsolateToken? token}) async {
    if (isDatabaseReady()) {
      await _db!.close();
      _db = null;
    }
  }

  bool isDatabaseReady() {
    return _db != null;
  }

  AppDatabase get db {
    return _db!;
  }

  Map<String, dynamic> get map {
    return {
      "dbPath": dbPath,
      "password": password,
      "nonce": nonce,
      "mediaDir": mediaDir.path,
    };
  }
}
