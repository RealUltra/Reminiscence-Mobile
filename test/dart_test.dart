import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:reminiscence/features/encryption/encryption.dart';
import 'package:reminiscence/features/encryption/kdf.dart';

void main() async {
  final nonce = await File("./test/data/nonce.txt").readAsBytes();
  final derivedKey = await deriveKey(password: '1234567890', nonce: nonce);

  await for (final file in Directory("./test/data/media").list()) {
    final filename = p.basename(file.path);
    final inputStream = InputFileStream(file.path);

    await decryptStream(
      inputStream: inputStream,
      outputPath: p.join("./test/decrypted", '${filename}_decrypted.mp4'),
      secretKey: derivedKey.secretKey,
    );

    print("Decrypted: $filename");
  }
}
