import 'package:cryptography/cryptography.dart';

import "package:reminiscence/features/encryption/utils.dart";

class DerivedKey {
  final SecretKey secretKey;
  final List<int> nonce;
  const DerivedKey({required this.secretKey, required this.nonce});
}

Future<DerivedKey> deriveKey({
  required String password,
  List<int>? nonce,
}) async {
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 100000,
    bits: 256,
  );

  nonce ??= generateNonce();

  final secretKey = await pbkdf2.deriveKeyFromPassword(
    password: password,
    nonce: nonce,
  );

  return DerivedKey(secretKey: secretKey, nonce: nonce);
}
