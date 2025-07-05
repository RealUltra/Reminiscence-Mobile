import 'dart:typed_data';

import 'package:reminiscence/features/reminiscence_file_io/components/page_header.dart';
import 'package:reminiscence/features/reminiscence_file_io/utils.dart';

class Page {
  final PageHeader header;
  late final Uint8List payload;

  Page({required this.header, Uint8List? payload}) {
    this.payload = payload ?? Uint8List(0);
  }

  factory Page.fromBytes(Uint8List bytes) {
    return Page(
      header: PageHeader.fromBytes(bytes.sublist(0, pageHeaderSize)),
      payload: bytes.sublist(pageHeaderSize),
    );
  }

  Uint8List toBytes() {
    final byteList = header.toBytes();
    byteList.addAll(payload);
    return byteList;
  }
}
