import 'dart:typed_data';

import 'package:reminiscence/features/reminiscence_file_io/components/page_type.dart';
import 'package:reminiscence/features/reminiscence_file_io/utils.dart';

class PageHeader {
  PageType pageType;
  int pageId;
  int nextPageId;
  int payloadSize;

  final _byteData = ByteData(pageHeaderSize);
  final _bytes = Uint8List(pageHeaderSize);

  PageHeader({
    required this.pageType,
    required this.pageId,
    this.nextPageId = 0,
    this.payloadSize = 0,
  });

  factory PageHeader.fromBytes(Uint8List bytes) {
    final sizedBytes = Uint8List(pageHeaderSize);

    if (bytes.length <= pageHeaderSize) {
      sizedBytes.setAll(0, bytes);
    } else {
      sizedBytes.setAll(0, Uint8List.sublistView(bytes, 0, pageHeaderSize));
    }

    final data = ByteData.sublistView(sizedBytes);

    final pageTypeValue = data.getUint8(0);
    // final flags = data.getUint8(1);
    final pageId = data.getUint32(2, Endian.little);
    final nextPageId = data.getUint32(6, Endian.little);
    final payloadSize = data.getUint16(10, Endian.little);

    return PageHeader(
      pageType: valueToPageType(pageTypeValue)!,
      pageId: pageId,
      nextPageId: nextPageId,
      payloadSize: payloadSize,
    );
  }

  Uint8List toBytes() {
    _byteData.setUint8(0, pageTypeToValue(pageType)); // Page Type
    _byteData.setUint8(1, 0); // Page Flags
    _byteData.setUint32(2, pageId, Endian.little); // Page ID
    _byteData.setUint32(6, nextPageId, Endian.little); // Next Page ID
    _byteData.setUint16(10, payloadSize, Endian.little); // Payload Size

    for (int i = 0; i < pageHeaderSize; i++) {
      _bytes[i] = _byteData.getUint8(i);
    }

    return _bytes;
  }
}
