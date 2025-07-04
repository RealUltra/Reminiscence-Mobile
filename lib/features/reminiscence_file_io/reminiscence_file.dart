import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:reminiscence/features/reminiscence_file_io/footer.dart';
import 'package:reminiscence/features/reminiscence_file_io/page.dart';
import 'package:reminiscence/features/reminiscence_file_io/page_header.dart';
import 'package:reminiscence/features/reminiscence_file_io/page_type.dart';
import 'package:reminiscence/features/reminiscence_file_io/metadata.dart';

const magicNumber = "REM0";
const pageHeaderSize = 12;
const pageSize = 4096;

final maxPayloadSize = pageSize - pageHeaderSize;

class ReminiscenceFile {
  late RandomAccessFile _file;

  ReminiscenceFile();

  Future<void> open(String path) async {
    _file = await File(path).open(mode: FileMode.append);

    await _file.setPosition(0);
    final magic = String.fromCharCodes(await _file.read(4));

    if (magic != magicNumber) {
      throw Exception(
        "Invalid rem file. Magic number '$magic' is not recognized.",
      );
    }
  }

  Future<void> create(String path) async {
    _file = await File(path).open(mode: FileMode.write);

    await writeMagicNumber();

    // Metadata page
    await writeMetadata(Metadata(footerPageId: 5));

    // Database root page
    await writePage(
      PageHeader(pageType: PageType.database, pageId: 2),
      Uint8List(4084),
    );

    // Media index root page
    await writePage(
      PageHeader(pageType: PageType.mediaIndexTable, pageId: 3),
      Uint8List(4084),
    );

    // Free page
    await writePage(
      PageHeader(pageType: PageType.free, pageId: 4),
      Uint8List(4084),
    );

    // Footer
    await writeFooter(
      Footer(dbRootPageId: 2, mediaIndexRootPageId: 3, freeListRootPageId: 4),
    );
  }

  Future<void> close() async {
    await _file.close();
  }

  Future<int> size() async {
    return await _file.length();
  }

  Future<int> pageCount() async {
    final fileSize = await size();
    return (fileSize / pageSize).toInt();
  }

  Future<void> writeMagicNumber() async {
    await _file.setPosition(0);
    await _file.writeFrom(Uint8List.fromList(utf8.encode(magicNumber)));
  }

  Future<void> writePage(PageHeader pageHeader, Uint8List payload) async {
    final pageId = pageHeader.pageId;
    final position = _getPagePosition(pageId);

    await _file.setPosition(position);

    pageHeader.payloadSize = min(maxPayloadSize, payload.length);
    await _file.writeFrom(pageHeader.toBytes());
    await _file.writeFrom(payload.sublist(0, pageHeader.payloadSize));
  }

  Future<void> writePayload(
    PageType pageType,
    int rootPageId,
    Uint8List payload,
  ) async {
    final position = _getPagePosition(rootPageId);
    await _file.setPosition(position);

    final numPages = (payload.length / maxPayloadSize).toInt() + 1;

    int pageId = rootPageId;
    int payloadStart = 0;

    for (int i = 0; i < numPages; i++) {
      final payloadEnd = min(payloadStart + maxPayloadSize, payload.length);
      final payloadSublist = payload.sublist(payloadStart, payloadEnd);

      final currentPageHeader = await readPageHeader(pageId);

      int nextPageId;

      if (i == numPages - 1) {
        nextPageId = 0;
      } else if (currentPageHeader.nextPageId != 0) {
        nextPageId = currentPageHeader.nextPageId;
      } else {
        nextPageId = await getFreePage(markAsUsed: true);
      }

      final header = PageHeader(
        pageType: pageType,
        pageId: pageId,
        nextPageId: nextPageId,
        payloadSize: payloadSublist.length,
      );

      await writePage(header, payloadSublist);

      payloadStart = payloadEnd;
      pageId = nextPageId;
    }
  }

  Future<void> writeMetadata(Metadata metadata) async {
    await writePage(
      PageHeader(pageType: PageType.metadata, pageId: 1),
      metadata.toBytes(),
    );
  }

  Future<void> writeFooter(Footer footer) async {
    await writePage(
      PageHeader(pageType: PageType.footer, pageId: 5),
      footer.toBytes(),
    );
  }

  Future<void> writeDatabase(Uint8List payload) async {
    final footer = await readFooter();
    final rootId = footer.dbRootPageId;
    await writePayload(PageType.database, rootId, payload);
  }

  Future<PageHeader> readPageHeader(int pageId) async {
    final position = _getPagePosition(pageId);
    await _file.setPosition(position);
    return PageHeader.fromBytes(await _file.read(pageHeaderSize));
  }

  Future<Page> readPage(int pageId) async {
    final position = _getPagePosition(pageId);
    await _file.setPosition(position);
    return Page.fromBytes(await _file.read(pageSize));
  }

  Stream<Uint8List> readPayload(int rootPageId) async* {
    int pageId = rootPageId;

    while (pageId != 0) {
      final page = await readPage(pageId);
      yield page.payload;
      pageId = page.header.nextPageId;
    }
  }

  Future<Metadata> readMetadata() async {
    final page = await readPage(1);
    return Metadata.fromBytes(page.payload);
  }

  Future<Footer> readFooter() async {
    final page = await readPage(5);
    return Footer.fromBytes(page.payload);
  }

  Future<void> readDatabaseToFile(File outputFile) async {
    final footer = await readFooter();
    final rootId = footer.dbRootPageId;

    final sink = outputFile.openWrite();

    await for (final buffer in readPayload(rootId)) {
      sink.add(buffer);
    }

    await sink.flush();
    await sink.close();
  }

  Future<int> getFreePage({bool markAsUsed = false}) async {
    final footer = await readFooter();
    final freePageId = footer.freeListRootPageId;

    if (markAsUsed) {
      final freePageHeader = await readPageHeader(freePageId);

      int nextFreePageId;

      if (freePageHeader.nextPageId != 0) {
        nextFreePageId = freePageHeader.nextPageId;
      } else {
        nextFreePageId = (await pageCount()) + 1;

        await writePage(
          PageHeader(pageType: PageType.free, pageId: nextFreePageId),
          Uint8List(4084),
        );
      }

      await writeFooter(
        Footer(
          dbRootPageId: footer.dbRootPageId,
          mediaIndexRootPageId: footer.mediaIndexRootPageId,
          freeListRootPageId: nextFreePageId,
        ),
      );
    }

    return freePageId;
  }

  int _getPagePosition(int pageId) {
    return (pageId - 1) * pageSize + magicNumber.length;
  }
}
