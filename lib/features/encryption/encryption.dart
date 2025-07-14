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

Stream<List<int>> encryptStream({
  required InputStream inputStream,
  required SecretKey secretKey,
  int chunkSize = 64 * 1024,
}) async* {
  final algorithm = AesGcm.with256bits();
  final nonce = generateNonce(length: 12);

  Mac? outputMac;

  final encryptedStream = algorithm.encryptStream(
    getStreamFromInputStream(stream: inputStream, chunkSize: chunkSize),
    secretKey: secretKey,
    nonce: nonce,
    onMac: (Mac mac) {
      outputMac = mac;
    },
  );

  List<int> emptyMac = [];

  for (int i = 0; i < 16; i++) {
    emptyMac.add(0);
  }

  yield nonce;
  yield outputMac?.bytes ?? emptyMac;

  await for (final chunk in encryptedStream) {
    yield chunk;
  }
}

Future<void> decryptStream({
  required Stream<List<int>> stream,
  required String outputPath,
  required SecretKey secretKey,
  int chunkSize = 64 * 1024,
}) async {
  final splitStream = splitEncryptedStream(stream);
  final iterator = StreamIterator(splitStream);

  await iterator.moveNext();

  final nonce = iterator.current;

  await iterator.moveNext();

  final macBytes = iterator.current;
  final mac = Mac(macBytes);

  await iterator.moveNext();

  final algorithm = AesGcm.with256bits();

  final output = File(outputPath).openWrite();

  final decryptedStream = algorithm.decryptStream(
    splitStream,
    secretKey: secretKey,
    nonce: nonce,
    mac: mac,
  );

  await output.addStream(decryptedStream);

  await output.close();
}

Stream<List<int>> splitEncryptedStream(Stream<List<int>> stream) async* {
  final iterator = StreamIterator(stream);

  final bytes = <int>[];

  while (await iterator.moveNext() && bytes.length < 28) {
    bytes.addAll(iterator.current);
  }
  
  yield bytes.sublist(0, 12);
  yield bytes.sublist(12, 28);

  yield bytes.sublist(28);

  while (await iterator.moveNext()) {
    yield iterator.current;
  }
}