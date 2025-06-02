import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:reminiscence/features/encryption/encryption.dart';

void main() async {
  /*
  final file = File(
    "B:\\UserData\\Documents\\Albums\\School\\A2 Events\\Class Photograph\\solo photo.png",
  );

  final inputStream = file.openRead();

  final derivedKey = await deriveKey(password: "1234567890");
  print(await derivedKey.secretKey.extractBytes());

  encryptStream(
    inputStream: inputStream,
    outputPath: "solo photo.png.encrypted",
    secretKey: derivedKey.secretKey,
  );
  */

  final secretKey = SecretKey([
    154,
    189,
    198,
    127,
    113,
    246,
    64,
    117,
    177,
    197,
    120,
    141,
    179,
    233,
    250,
    31,
    254,
    27,
    80,
    112,
    212,
    221,
    206,
    173,
    244,
    142,
    249,
    198,
    181,
    80,
    114,
    181,
  ]);

  final stopwatch = Stopwatch()..start();

  final inputFile = File(
    "B:\\UserData\\Desktop\\Programming Projects\\Flutter\\reminiscence\\solo photo.png.encrypted",
  );
  final outputFile = File("output.png");

  decryptStream(
    inputPath: inputFile.path,
    outputPath: outputFile.path,
    secretKey: secretKey,
  );

  stopwatch.stop();
}
