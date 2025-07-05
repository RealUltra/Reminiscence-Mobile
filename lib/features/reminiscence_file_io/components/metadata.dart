/*
| 12     | Metadata Version | 1            | The version of the meta page format                              |
| 13     | Metadata Flags   | 1            | Allocated for bit flags (encrypted)                              |
| 14     | Nonce            | 16           | The nonce required to derive the encryption key with kdf         |
| 30     | Encrypted Nonce  | 32           | Used to test if the decryption key is correct                    |
| 62     | Footer Page ID   | 4            | The page ID of the footer                                        |
| 66     | Reserved         | 4030         | Padding                                                          |
*/

import 'dart:math';
import 'dart:typed_data';

import 'package:reminiscence/features/reminiscence_file_io/utils.dart';

const int metadataVersion = 1;
const int nonceSize = 16;
const int encryptedNonceSize = 32;

const int flagEncrypted = 0x01;

class Metadata {
  final bool isEncrypted;
  late final Uint8List nonce;
  late final Uint8List encryptedNonce;
  final int footerPageId;

  Metadata({
    this.isEncrypted = false,
    Uint8List? nonce,
    Uint8List? encryptedNonce,
    required this.footerPageId,
  }) {
    this.nonce = nonce ?? Uint8List(0);
    this.encryptedNonce = encryptedNonce ?? Uint8List(0);
  }

  factory Metadata.fromBytes(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);

    // Read the version
    //final version = data.getUint8(0);

    // Read and parse flags
    final flags = data.getUint8(1);
    bool isEncrypted = (flags & flagEncrypted) != 0;

    // Read the nonce byte by byte
    Uint8List nonce = Uint8List(nonceSize);

    for (int i = 0; i < nonceSize; i++) {
      nonce[i] = data.getUint8(2 + i);
    }

    // Read the encrypted nonce byte by byte
    Uint8List encryptedNonce = Uint8List(encryptedNonceSize);

    for (int i = 0; i < encryptedNonceSize; i++) {
      encryptedNonce[i] = data.getUint8(18 + i);
    }

    final footerPageId = data.getUint32(50, Endian.little);

    return Metadata(
      isEncrypted: isEncrypted,
      nonce: nonce,
      encryptedNonce: encryptedNonce,
      footerPageId: footerPageId,
    );
  }

  Uint8List toBytes() {
    final data = ByteData(maxPayloadSize);

    data.setUint8(0, metadataVersion); // Metadata version
    data.setUint8(1, _getByteFlags()); // Page Flags

    // Add nonce byte by byte
    for (int i = 0; i < min(nonceSize, nonce.length); i++) {
      data.setUint8(2 + i, nonce[i]);
    }

    // Add the encrypted nonce byte by byte
    for (int i = 0; i < min(encryptedNonceSize, encryptedNonce.length); i++) {
      data.setUint8(18 + i, encryptedNonce[i]);
    }

    data.setUint32(50, footerPageId, Endian.little); // The footer's page id

    return data.buffer.asUint8List();
  }

  int _getByteFlags() {
    int flags = 0;

    if (isEncrypted) {
      flags = flags | flagEncrypted;
    }

    return flags;
  }
}
