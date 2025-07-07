import 'dart:io';
import 'package:collection/collection.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import 'package:reminiscence/features/encryption/encryption.dart';
import 'package:reminiscence/features/encryption/kdf.dart';
import 'package:reminiscence/features/reminiscence_file_io/reminiscence_file.dart';

Future<bool> isRemFileEncrypted(String filePath) async {
  final file = ReminiscenceFile();

  try {
    await file.open(filePath);
  } catch (e) {
    return false;
  }

  final isEncrypted = file.isEncrypted();

  await file.close();

  return isEncrypted;
}

Future<bool> checkPassword(String remFilePath, String? password) async {
  if (password == null) {
    return !(await isRemFileEncrypted(remFilePath));
  }

  InputFileStream stream = InputFileStream(remFilePath);
  Archive archive = ZipDecoder().decodeStream(stream);

  ArchiveFile? nonceFile = archive.find("nonce.txt");
  List<int> nonce = nonceFile!.readBytes() ?? [];

  ArchiveFile? testFile = archive.find("test.dat");
  List<int> encryptionTest = testFile?.readBytes() ?? [];

  DerivedKey derivedKey = await deriveKey(password: password, nonce: nonce);

  try {
    List<int> decryptedTest = await decrypt(
      encryptionTest,
      derivedKey.secretKey,
    );
    return ListEquality().equals(nonce, decryptedTest);
  } catch (e) {
    return false;
  }
}

Future<bool> isValidRemFile(String filePath) async {
  final file = ReminiscenceFile();

  try {
    await file.open(filePath);
    return true;
  } catch (_) {
    return false;
  }
}

Future<void> extractArchiveDir(
  Archive archive,
  String directory,
  Directory outputDir,
) async {
  directory = p.normalize(directory);

  for (ArchiveFile archiveFile in archive) {
    final archiveFileName = p.normalize(archiveFile.name);

    if (archiveFileName.startsWith(directory)) {
      String relativeDir = p.relative(
        p.dirname(archiveFileName),
        from: directory,
      );
      final filePath = p.join(
        outputDir.path,
        relativeDir,
        p.basename(archiveFile.name),
      );

      if (archiveFile.isFile) {
        await Directory(p.dirname(filePath)).create(recursive: true);

        final stream = OutputFileStream(filePath);
        stream.writeStream(archiveFile.rawContent!.getStream());
        await stream.close();
      }
    }
  }
}
