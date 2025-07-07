import 'dart:io';
import 'dart:ui';
import 'package:cryptography/cryptography.dart';

import 'package:reminiscence/features/database/database.dart';
import 'package:reminiscence/features/encryption/kdf.dart';
import 'package:reminiscence/features/reminiscence_file_io/reminiscence_file.dart';

class ReminiscenceData {
  final ReminiscenceFile file;
  final String dbPath;
  final String? password;
  final List<int> nonce;
  late final SecretKey? secretKey;
  final Directory tempDir;

  AppDatabase? _db;

  ReminiscenceData({
    required this.file,
    required this.dbPath,
    required this.password,
    required this.nonce,
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
      file: ReminiscenceFile()..open(data["filePath"]),
      dbPath: data["dbPath"],
      password: data["password"],
      nonce: data["nonce"],
      tempDir: Directory(data["tempDir"]),
    );
  }

  void loadDatabase({RootIsolateToken? token}) {
    _db ??= AppDatabase(dbPath: dbPath, password: password, token: token);
  }

  Future<void> close() async {
    if (isDatabaseReady()) {
      await _db!.close();
      _db = null;
    }

    await file.close();
  }

  bool isDatabaseReady() {
    return _db != null;
  }

  AppDatabase get db {
    return _db!;
  }

  Map<String, dynamic> get map {
    return {
      "filePath": file.name,
      "dbPath": dbPath,
      "password": password,
      "nonce": nonce,
      "tempDir": tempDir.path,
    };
  }
}
