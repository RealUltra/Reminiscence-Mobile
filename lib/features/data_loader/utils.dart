import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

bool isRemFileEncrypted(String filePath) {
  InputFileStream stream = InputFileStream(filePath);
  Archive archive = ZipDecoder().decodeStream(stream);

  ArchiveFile? archiveFile = archive.find("nonce.txt");
  List<int>? bytes = archiveFile?.readBytes();

  if (archiveFile == null ||
      !archiveFile.isFile ||
      bytes == null ||
      bytes.isEmpty) {
    return false;
  }

  return true;
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
        stream.writeStream(archiveFile.getContent()!);
        await stream.close();
      }
    }
  }
}
