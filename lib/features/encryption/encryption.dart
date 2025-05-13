import 'package:cryptography/cryptography.dart';

import "package:reminiscence/features/encryption/utils.dart";

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
