/*
| 12     | Footer Version              | 1            | The version of the footer page format                            |
| 13     | Footer Flags                | 1            | Allocated but unused                                             |
| 14     | DB Root Page ID             | 4            | The id of the first database page                                |
| 18     | Media Index Root Page ID    | 4            | The id of the first media index page                             |
| 22     | Free List Root Page ID      | 4            | The id of the first free page                                    |
| 66     | Reserved                    | 4070         |                                                                  |
*/

import 'dart:typed_data';

const int footerVersion = 1;

class Footer {
  int dbRootPageId;
  int mediaIndexRootPageId;
  int freeListRootPageId;
  int pageCount;

  Footer({
    required this.dbRootPageId,
    required this.mediaIndexRootPageId,
    required this.freeListRootPageId,
    required this.pageCount,
  });

  factory Footer.fromBytes(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);

    // Footer version
    // final version = data.getUint8(0);

    // Flags
    // final flags = data.getUint8(1);

    final dbRootPageId = data.getUint32(2, Endian.little);
    final mediaIndexRootPageId = data.getUint32(6, Endian.little);
    final freeListRootPageId = data.getUint32(10, Endian.little);
    final pageCount = data.getUint32(14, Endian.little);

    return Footer(
      dbRootPageId: dbRootPageId,
      mediaIndexRootPageId: mediaIndexRootPageId,
      freeListRootPageId: freeListRootPageId,
      pageCount: pageCount,
    );
  }

  Uint8List toBytes() {
    final data = ByteData(30);

    data.setUint8(0, footerVersion); // Current footer version

    data.setUint8(1, 0); // Page Flags

    data.setUint32(
      2,
      dbRootPageId,
      Endian.little,
    ); // The first page of the database

    data.setUint32(
      6,
      mediaIndexRootPageId,
      Endian.little,
    ); // The first page of the media index table

    data.setUint32(
      10,
      freeListRootPageId,
      Endian.little,
    ); // The first page of the free list

    data.setUint32(
      14,
      pageCount,
      Endian.little,
    ); // The number of pages currently in use by the file

    return data.buffer.asUint8List();
  }
}
