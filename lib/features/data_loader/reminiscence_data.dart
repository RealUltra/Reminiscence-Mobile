import 'dart:io';
import 'dart:ui';
import 'package:cryptography/cryptography.dart';

import 'package:reminiscence/features/database/database.dart';
import 'package:reminiscence/features/encryption/kdf.dart';

class ReminiscenceData {
  final String remFilePath;
  final String dbPath;
  final String? password;
  final List<int> nonce;
  late final SecretKey? secretKey;
  final Directory mediaDir;
  final Directory tempDir;

  AppDatabase? _db;

  ReminiscenceData({
    required this.remFilePath,
    required this.dbPath,
    required this.password,
    required this.nonce,
    required this.mediaDir,
    required this.tempDir,
  }) {
    if (password == null) {
      secretKey = null;
    } else {
      deriveKey(
        password: password!,
        nonce: nonce,
      ).then((key) => secretKey = key.secretKey);
    }
  }

  static ReminiscenceData fromMap(Map<String, dynamic> data) {
    return ReminiscenceData(
      remFilePath: data["remFilePath"],
      dbPath: data["dbPath"],
      password: data["password"],
      nonce: data["nonce"],
      mediaDir: Directory(data["mediaDir"]),
      tempDir: Directory(data["tempDir"]),
    );
  }

  void loadDatabase({RootIsolateToken? token}) {
    _db ??= AppDatabase(dbPath: dbPath, password: password, token: token);
  }

  Future<void> closeDatabase() async {
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
      "remFilePath": remFilePath,
      "dbPath": dbPath,
      "password": password,
      "nonce": nonce,
      "mediaDir": mediaDir.path,
      "tempDir": tempDir.path,
    };
  }
}
