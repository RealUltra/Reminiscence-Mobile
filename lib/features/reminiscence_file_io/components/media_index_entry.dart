import 'dart:typed_data';

import 'package:reminiscence/features/reminiscence_file_io/components/utils.dart';

class MediaIndexEntry {
  int attachmentId;
  int mediaRootPageId;

  MediaIndexEntry({required this.attachmentId, required this.mediaRootPageId});

  factory MediaIndexEntry.fromBytes(Uint8List bytes) {
    final byteData = ByteData.sublistView(bytes);

    final attachmentId = byteData.getUint32(0, Endian.little);
    final mediaRootPageId = byteData.getUint32(4, Endian.little);

    return MediaIndexEntry(
      attachmentId: attachmentId,
      mediaRootPageId: mediaRootPageId,
    );
  }

  Uint8List toBytes() {
    final byteData = ByteData(mediaIndexEntrySize);

    byteData.setUint32(0, attachmentId, Endian.little);
    byteData.setUint32(4, mediaRootPageId, Endian.little);

    return byteData.buffer.asUint8List();
  }
}
