import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:reminiscence/features/data_loader/utils.dart';

void main() async {
  final String archivePath =
      "B:/UserData/Documents/Instagram Data Downloads/instagram-bss_2024-2024-01-17-QZzMumC1.zip";

  InputFileStream stream = InputFileStream(archivePath);
  Archive archive = ZipDecoder().decodeStream(stream);

  await extractArchiveDir(archive, "your_instagram_activity", "output");
}
