import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:reminiscence/features/data_loader/utils.dart';

import "package:reminiscence/features/data_loader/reminiscence_data.dart";
import 'package:reminiscence/features/database/database.dart';

Future<ReminiscenceData?> loadRemFile({
  required String filePath,
  String? password,
  required RootIsolateToken rootToken,
  required SendPort? sendPort,
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
  final Directory mediaDir = Directory(p.join(tempDir.path, "media"));

  if (isCancelled) return null;

  // Open the rem file
  InputFileStream stream = InputFileStream(filePath);
  Archive archive = ZipDecoder().decodeStream(stream);

  // Get the database and nonce files from the rem file.
  ArchiveFile? databaseArchiveFile = archive.find("database.db");
  ArchiveFile? nonceArchiveFile = archive.find("nonce.txt");

  // Extract the database
  if (databaseArchiveFile == null) {
    return null;
  }

  if (isCancelled) return null;

  sendPort?.send({
    "type": "progress",
    "progress": {"value": 0.0, "label": 'Preparing Chat Messages...'},
  });

  // Extract the database file.
  final dbStream = OutputFileStream(dbPath);
  databaseArchiveFile.writeContent(dbStream);
  await dbStream.close();

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

  // Get the nonce
  List<int> nonce = [];

  if (nonceArchiveFile != null) {
    nonce = nonceArchiveFile.readBytes() ?? [];
  }

  if (isCancelled) return null;

  sendPort?.send({
    "type": "progress",
    "progress": {"value": 0.5, "label": 'Preparing Chat Media...'},
  });

  // Extract the media files
  if (await mediaDir.exists()) {
    await mediaDir.delete(recursive: true);
  }

  if (isCancelled) return null;

  await extractArchiveDir(archive, "media", mediaDir);

  if (isCancelled) return null;

  sendPort?.send({
    "type": "progress",
    "progress": {"value": 1.0},
  });

  return ReminiscenceData(
    filePath: filePath,
    dbPath: dbPath,
    password: password,
    nonce: nonce,
    mediaDir: mediaDir,
    tempDir: tempDir,
  );
}
