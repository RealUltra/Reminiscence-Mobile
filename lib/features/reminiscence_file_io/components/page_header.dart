import 'dart:typed_data';

import 'package:reminiscence/features/reminiscence_file_io/components/page_type.dart';

class PageHeader {
  PageType pageType;
  int pageId;
  int nextPageId;
  int payloadSize;

  PageHeader({
    required this.pageType,
    required this.pageId,
    this.nextPageId = 0,
    this.payloadSize = 0,
  });

  factory PageHeader.fromBytes(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);

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
    final data = ByteData(12);

    data.setUint8(0, pageTypeToValue(pageType)); // Page Type
    data.setUint8(1, 0); // Page Flags
    data.setUint32(2, pageId, Endian.little); // Page ID
    data.setUint32(6, nextPageId, Endian.little); // Next Page ID
    data.setUint16(10, payloadSize, Endian.little); // Payload Size

    return data.buffer.asUint8List();
  }
}
