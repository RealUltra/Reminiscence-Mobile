import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:reminiscence/features/data_loader/utils.dart';

import 'package:reminiscence/features/database/database.dart';
import "package:reminiscence/features/data_loader/reminiscence_file.dart";

Future<ReminiscenceFile?> loadRemFile(String filePath, String? password) async {
  final Directory tempDir = await getTemporaryDirectory();
  final String databasePath = p.join(tempDir.path, "database.db");
  final Directory mediaDir = Directory(p.join(tempDir.path, "media"));

  InputFileStream stream = InputFileStream(filePath);
  Archive archive = ZipDecoder().decodeStream(stream);

  ArchiveFile? databaseArchiveFile = archive.find("database.db");
  ArchiveFile? nonceArchiveFile = archive.find("nonce.txt");

  // Extract the database
  if (databaseArchiveFile == null) {
    return null;
  }

  final dbStream = OutputFileStream(databasePath);
  databaseArchiveFile.writeContent(dbStream);
  await dbStream.close();

  // Get the nonce
  List<int> nonce = [];

  if (nonceArchiveFile != null) {
    nonce = nonceArchiveFile.readBytes() ?? [];
  }

  // Extract the media files
  await mediaDir.delete(recursive: true);
  await extractArchiveDir(archive, "media", mediaDir);

  // Load the database
  AppDatabase db = AppDatabase(dbPath: databasePath, password: password);

  return ReminiscenceFile(db: db, nonce: nonce, mediaDir: mediaDir);
}
