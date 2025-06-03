import 'dart:io';

import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';
import 'package:reminiscence/features/encryption/encryption.dart';
import 'package:reminiscence/features/encryption/kdf.dart';

void main() async {
  /*
  final inputStream = InputFileStream(
    "B:\\UserData\\Documents\\Albums\\School\\A2 Events\\Class Photograph\\solo photo.png",
  );

  final derivedKey = await deriveKey(password: "1234567890");
  print(derivedKey.nonce);

  encryptStream(
    inputStream: inputStream,
    outputPath: "solo photo.png.encrypted",
    secretKey: derivedKey.secretKey,
  );
  */

  ///*
  final nonce = [
    53,
    195,
    214,
    157,
    27,
    188,
    155,
    28,
    192,
    124,
    76,
    85,
    29,
    56,
    212,
    36,
  ];

  final derivedKey = await deriveKey(password: "1234567890", nonce: nonce);

  final stopwatch = Stopwatch()..start();

  final inputFile = File(
    "B:\\UserData\\Desktop\\Programming Projects\\Flutter\\reminiscence\\solo photo.png.encrypted",
  );
  final outputFile = File("output.png");

  decryptStream(
    inputStream: InputFileStream(inputFile.path),
    outputPath: outputFile.path,
    secretKey: derivedKey.secretKey,
  );

  stopwatch.stop();
  //*/
}
