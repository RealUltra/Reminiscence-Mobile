import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import "package:reminiscence/features/data_loader/reminiscence_data.dart";
import 'package:reminiscence/features/database/database.dart';
import 'package:reminiscence/features/reminiscence_file_io/reminiscence_file.dart';

Future<ReminiscenceData?> loadRemFile({
  required String filePath,
  String? password,
  required RootIsolateToken rootToken,
  required SendPort? sendPort,
  double progressStart = 0.0,
  double progressValue = 1.0, 
}) async {
  // Set up receive port and cancellation token
  ReceivePort? receivePort = sendPort != null ? ReceivePort() : null;
  bool isCancelled = false;

  if (receivePort != null) {
    sendPort!.send({"type": "sendPort", "sendPort": receivePort.sendPort});
  }

  receivePort?.listen((message) {
    if (message is! Map<String, dynamic>) return;

    if (message["type"] == "cancel") {
      isCancelled = true;
    }
  });

  // Prepare all the extracted paths
  final Directory tempDir = await getTemporaryDirectory();
  final String dbPath = p.join(tempDir.path, "database.db");

  // Open the rem file
  final remFile = ReminiscenceFile();
  await remFile.open(filePath);

  if (isCancelled) return null;

  sendPort?.send({
    "type": "progress",
    "progress": {"value": progressStart, "label": 'Preparing Chat Messages...'},
  });

  // Extract the database file.
  await remFile.writeDatabaseToFile(File(dbPath));

  if (isCancelled) return null;

  // Try to decrypt the database to check if the password is correct.
  final db = AppDatabase(dbPath: dbPath, password: password, token: rootToken);

  try {
    await db.chats.select().get();
    await db.close();
  } catch (_) {
    await db.close();
    return null;
  }

  if (isCancelled) return null;

  // Get the nonce
  final nonce = remFile.isEncrypted() ? remFile.nonce : <int>[];

  sendPort?.send({
    "type": "progress",
    "progress": {"value": progressStart + progressValue},
  });

  return ReminiscenceData(
    file: remFile,
    dbPath: dbPath,
    password: password,
    nonce: nonce,
    tempDir: tempDir,
  );
}
