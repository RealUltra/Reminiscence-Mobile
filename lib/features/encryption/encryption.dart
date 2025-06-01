import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';

import "package:reminiscence/features/encryption/utils.dart";

Stream<List<int>> getStreamFromInputStream({
  required InputStream stream,
  int chunkSize = 64 * 1024,
}) async* {
  while (!stream.isEOS) {
    yield stream.readBytes(chunkSize).toUint8List();
  }
}

Future<List<int>> encrypt(List<int> data, SecretKey secretKey) async {
  final algorithm = AesGcm.with256bits();

  final nonce = generateNonce(length: 12);

  final encrypted = await algorithm.encrypt(
    data,
    secretKey: secretKey,
    nonce: nonce,
  );

  return nonce + encrypted.mac.bytes + encrypted.cipherText;
}

Future<List<int>> decrypt(List<int> encryptedData, SecretKey secretKey) async {
  final algorithm = AesGcm.with256bits();

  final nonce = encryptedData.sublist(0, 12);
  final mac = Mac(encryptedData.sublist(12, 28));
  final cipherText = encryptedData.sublist(28);

  final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);
  final decrypted = await algorithm.decrypt(secretBox, secretKey: secretKey);

  return decrypted;
}

Future<void> encryptStream({
  required InputStream inputStream,
  required String outputPath,
  required SecretKey secretKey,
  int chunkSize = 64 * 1024,
}) async {
  final outputStream = File(outputPath).openWrite();

  final algorithm = AesGcm.with256bits();
  final nonce = generateNonce(length: 12);

  outputStream.add(nonce);

  Mac? outputMac;

  final encryptedStream = algorithm.encryptStream(
    getStreamFromInputStream(stream: inputStream, chunkSize: chunkSize),
    secretKey: secretKey,
    nonce: nonce,
    onMac: (Mac mac) {
      outputMac = mac;
    },
  );

  await outputStream.addStream(encryptedStream);
  outputStream.add(outputMac?.bytes ?? []);
}

Future<void> decryptStream({
  required String inputPath,
  required String outputPath,
  required SecretKey secretKey,
  int chunkSize = 64 * 1024,
}) async {
  final inputFile = File(inputPath);
  final fileLength = await inputFile.length();

  if (fileLength < 28) {
    throw Exception("The file is too short to contain the nonce and the mac.");
  }

  final nonce = await inputFile
      .openRead(0, 12)
      .fold<List<int>>([], (a, b) => a..addAll(b));

  final macStart = fileLength - 16;
  final macBytes = await inputFile
      .openRead(macStart)
      .fold<List<int>>([], (a, b) => a..addAll(b));
  final mac = Mac(macBytes);

  final algorithm = AesGcm.with256bits();

  final input = inputFile.openRead(12, macStart);
  final output = File(outputPath).openWrite();

  final decryptedStream = algorithm.decryptStream(
    input,
    secretKey: secretKey,
    nonce: nonce,
    mac: mac,
  );

  await output.addStream(decryptedStream);
}
