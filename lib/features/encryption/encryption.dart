import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
//import 'package:path_provider/path_provider.dart';

import "package:reminiscence/features/encryption/utils.dart";

Stream<List<int>> _streamToInputStream({
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
  // Prepare the algorithm
  final algorithm = AesGcm.with256bits();

  // Generate a new nonce for this file.
  final nonce = generateNonce(length: 12);

  // Prepare the variable for the mac.
  late Mac outputMac;

  // Encrypt the data and stream the encrypted data.
  final encryptedStream = algorithm.encryptStream(
    _streamToInputStream(stream: inputStream, chunkSize: chunkSize),
    secretKey: secretKey,
    nonce: nonce,
    onMac: (Mac mac) {
      outputMac = mac;
    },
  );

  // Prepare the temporary file to store the encrypted data.
  final tempDir = await getTemporaryDirectory();
  final tempFile = File(p.join(tempDir.path, "temp.encrypted"));
  final sink = tempFile.openWrite();
  await for (final chunk in encryptedStream) {
    sink.add(chunk);
  }
  await sink.close();

  // Output the nonce & mac to the encrypted file.
  yield nonce;
  yield outputMac.bytes;

  // Read the encrypted data back from the temporary file and output it.
  final tempFileStream = tempFile.openRead();
  await for (final chunk in tempFileStream) {
    yield chunk;
  }
}

Future<void> decryptStream({
  required Stream<List<int>> stream,
  required File outputFile,
  required SecretKey secretKey,
  int chunkSize = 64 * 1024,
}) async {
  // This special stream will allow us to get the nonce & mac separately first.
  final splitStream = _splitEncryptedStream(stream);

  // An iterator to get items from the stream one by one.
  final iterator = StreamIterator(splitStream);

  // Get the nonce
  await iterator.moveNext();
  final nonce = iterator.current;

  // Get the mac
  await iterator.moveNext();
  final macBytes = iterator.current;
  final mac = Mac(macBytes);

  // Prepare the algorithm.
  final algorithm = AesGcm.with256bits();

  // Decrypt the encrypted data within the input stream (nonce & mac ignored).
  final decryptedStream = algorithm.decryptStream(
    _restOfStream(iterator),
    secretKey: secretKey,
    nonce: nonce,
    mac: mac,
  );

  // Write the decrypted stream to the output file.
  final output = outputFile.openWrite();
  await output.addStream(decryptedStream);
  await output.close();

  // Cancel the iterator
  await iterator.cancel();
}

Stream<List<int>> _splitEncryptedStream(Stream<List<int>> stream) async* {
  final iterator = StreamIterator(stream);

  final bytes = <int>[];

  while (bytes.length < 28 && await iterator.moveNext()) {
    bytes.addAll(iterator.current);
  }
  
  yield bytes.sublist(0, 12);
  yield bytes.sublist(12, 28);

  if (bytes.length > 28) {
    yield bytes.sublist(28);
  }

  while (await iterator.moveNext()) {
    yield iterator.current;
  }

  await iterator.cancel();
}

Stream<List<int>> _restOfStream(StreamIterator<List<int>> iterator) async* {
  while (await iterator.moveNext()) {
    final chunk = iterator.current;
    yield chunk;
  }
}