import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:reminiscence/features/reminiscence_file_io/components/footer.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/media_index_entry.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/media_index_table.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/page.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/page_header.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/page_type.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/metadata.dart';

const magicNumber = "REM0";
const pageSize = 4096;
const pageHeaderSize = 12;
final mediaIndexEntrySize = 8;

final maxPayloadSize = pageSize - pageHeaderSize;

class ReminiscenceFile {
  late RandomAccessFile _file;

  ReminiscenceFile();

  Future<void> open(String path) async {
    _file = await File(path).open(mode: FileMode.append);

    if (!(await validateMagicNumber())) {
      throw Exception("Invalid rem file. Magic number not recognized.");
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
      Uint8List(0),
    );

    // Media index root page
    await writePage(
      PageHeader(pageType: PageType.mediaIndex, pageId: 3),
      Uint8List(0),
    );

    // Free page
    await writePage(
      PageHeader(pageType: PageType.free, pageId: 4),
      Uint8List(0),
    );

    // Footer
    await writeFooter(
      Footer(dbRootPageId: 2, mediaIndexRootPageId: 3, freeListRootPageId: 4),
    );
  }

  Future<void> close() => _file.close();

  Future<int> size() => _file.length();

  Future<int> pageCount() async {
    final fileSize = await size();
    return (fileSize / pageSize).toInt();
  }

  Future<bool> validateMagicNumber() async {
    await _file.setPosition(0);
    final magic = String.fromCharCodes(await _file.read(4));
    return magic == magicNumber;
  }

  Future<void> writeMagicNumber() async {
    await _file.setPosition(0);
    await _file.writeFrom(Uint8List.fromList(utf8.encode(magicNumber)));
  }

  Future<void> writePageHeader(PageHeader pageHeader) async {
    final pageId = pageHeader.pageId;
    final position = _getPagePosition(pageId);

    await _file.setPosition(position);
    await _file.writeFrom(pageHeader.toBytes());
  }

  Future<void> writePage(PageHeader pageHeader, Uint8List payload) async {
    final pageId = pageHeader.pageId;
    final position = _getPagePosition(pageId);

    await _file.setPosition(position);

    final payloadSize = min(maxPayloadSize, payload.length);
    pageHeader.payloadSize = payloadSize;

    final sizedPayload = Uint8List(maxPayloadSize);
    sizedPayload.setAll(0, payload.sublist(0, payloadSize));

    await _file.writeFrom(pageHeader.toBytes());
    await _file.writeFrom(sizedPayload);

    if (payload.length > maxPayloadSize) {
      final nextPageId = await getFreePage(markAsUsed: true);

      pageHeader.nextPageId = nextPageId;
      await writePageHeader(pageHeader);

      await writePage(
        PageHeader(pageType: pageHeader.pageType, pageId: nextPageId),
        payload.sublist(maxPayloadSize),
      );
    }
  }

  Future<void> appendToPage(
    PageType pageType,
    int pageId,
    Uint8List payload,
  ) async {
    final chainIds = await getPageChainIds(pageId);

    if (chainIds.isEmpty) {
      await writePage(PageHeader(pageType: pageType, pageId: pageId), payload);
    }

    final lastPageId = chainIds.last;
    final pageHeader = await readPageHeader(lastPageId);

    if (pageHeader.payloadSize != 0 &&
        pageHeader.payloadSize != maxPayloadSize) {
      final offset = pageHeader.payloadSize;
      final position = _getPagePosition(lastPageId);
      _file.setPosition(position + offset);

      final pageCapacity = maxPayloadSize - offset;
      final sizedPayload = payload.sublist(0, pageCapacity);
      payload = payload.sublist(pageCapacity);

      _file.writeFrom(sizedPayload);

      pageHeader.payloadSize += sizedPayload.length;
    }

    pageHeader.nextPageId = await getFreePage(markAsUsed: true);
    await writePageHeader(pageHeader);

    await writePage(
      PageHeader(pageType: pageType, pageId: pageHeader.nextPageId),
      payload,
    );
  }

  Stream<List<int>> getByteStream(Uint8List bytes, {int? packetSize}) async* {
    packetSize ??= maxPayloadSize;

    int offset = 0;

    while (offset < bytes.length) {
      final byteCount = min(packetSize, bytes.length);
      yield bytes.sublist(offset, byteCount);
      offset += byteCount;
    }
  }

  Future<void> streamPayload(
    PageType pageType,
    int rootPageId,
    Stream<List<int>> stream,
  ) async {
    final pageHeader = await readPageHeader(rootPageId);

    if (pageHeader.nextPageId != 0) {
      await addToFreeList(pageHeader.nextPageId);
    }

    List<int> buffer = [];
    int pageId = rootPageId;
    int offset = 0;

    await for (final bytes in stream) {
      buffer.addAll(bytes);

      while (buffer.isNotEmpty) {
        final pageCapacity = maxPayloadSize - offset;

        final payload = buffer.sublist(0, min(pageCapacity, buffer.length));
        buffer = buffer.sublist(payload.length);

        final pageHeader = await readPageHeader(pageId);
        int nextPageId;

        if ((offset + payload.length) < maxPayloadSize) {
          nextPageId = 0;
        } else if (pageHeader.nextPageId != 0) {
          nextPageId = pageHeader.nextPageId;
        } else {
          nextPageId = await getFreePage(markAsUsed: true);
        }

        final newPageHeader = PageHeader(
          pageType: pageType,
          pageId: pageId,
          nextPageId: nextPageId,
          payloadSize: payload.length,
        );

        if (offset > 0) {
          newPageHeader.payloadSize += pageHeader.payloadSize;
        }

        await writePageHeader(newPageHeader);

        final position = _getPagePosition(pageId);
        await _file.setPosition(position + pageHeaderSize + offset);

        await _file.writeFrom(payload);

        if (nextPageId != 0) {
          pageId = nextPageId;
          offset = 0;
        } else {
          offset += payload.length;
        }
      }
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

  Future<void> writeDatabase(File dbFile) async {
    final footer = await readFooter();
    final rootId = footer.dbRootPageId;
    await streamPayload(PageType.database, rootId, dbFile.openRead());
  }

  Future<void> addToMediaIndex(MediaIndexEntry entry) async {
    final footer = await readFooter();
    final rootId = footer.mediaIndexRootPageId;

    PageHeader currentHeader = await readPageHeader(rootId);

    while (currentHeader.nextPageId != 0) {
      currentHeader = await readPageHeader(currentHeader.nextPageId);
    }

    final lastPage = await readPage(currentHeader.pageId);

    final payload = Uint8List(
      lastPage.header.payloadSize + mediaIndexEntrySize,
    );

    payload.setAll(0, lastPage.payload.sublist(0, lastPage.header.payloadSize));
    payload.setAll(lastPage.header.payloadSize, entry.toBytes());

    await writePage(
      PageHeader(pageType: PageType.mediaIndex, pageId: lastPage.header.pageId),
      payload,
    );
  }

  Future<void> addMediaFile(int attachmentId, File file) async {
    final mediaRootPageId = await getFreePage(markAsUsed: true);
    final mediaIndexEntry = MediaIndexEntry(
      attachmentId: attachmentId,
      mediaRootPageId: mediaRootPageId,
    );

    await addToMediaIndex(mediaIndexEntry);

    await streamPayload(PageType.media, mediaRootPageId, file.openRead());
  }

  Future<void> addToFreeList(int rootPageId) async {
    final chainIds = await getPageChainIds(rootPageId);

    for (final pageId in chainIds) {
      await writePage(
        PageHeader(pageType: PageType.free, pageId: pageId),
        Uint8List(0),
      );
    }

    final footer = await readFooter();
    final freeList = await getPageChainIds(footer.freeListRootPageId);

    await writePageHeader(
      PageHeader(
        pageType: PageType.free,
        pageId: freeList.last,
        nextPageId: rootPageId,
      ),
    );
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
      yield page.payload.sublist(0, page.header.payloadSize);
      pageId = page.header.nextPageId;
    }
  }

  Future<void> readPayloadToFile(int rootPageId, File outputFile) async {
    final sink = outputFile.openWrite();

    await for (final buffer in readPayload(rootPageId)) {
      sink.add(buffer);
    }

    await sink.flush();
    await sink.close();
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
    await readPayloadToFile(rootId, outputFile);
  }

  Future<MediaIndexTable> readMediaIndex() async {
    final footer = await readFooter();
    final rootId = footer.mediaIndexRootPageId;

    List<int> payload = [];

    await for (final buffer in readPayload(rootId)) {
      payload.addAll(buffer);
    }

    return MediaIndexTable.fromBytes(Uint8List.fromList(payload));
  }

  Future<void> readMediaToFile(int attachmentId, File outputFile) async {
    final mediaIndex = await readMediaIndex();

    for (final entry in mediaIndex.entries) {
      if (entry.attachmentId == attachmentId) {
        await readPayloadToFile(entry.mediaRootPageId, outputFile);
        return;
      }
    }
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
          Uint8List(0),
        );
      }

      await writeFooter(
        Footer(
          dbRootPageId: footer.dbRootPageId,
          mediaIndexRootPageId: footer.mediaIndexRootPageId,
          freeListRootPageId: nextFreePageId,
        ),
      );

      await writePageHeader(
        PageHeader(pageType: PageType.free, pageId: freePageId),
      );
    }

    return freePageId;
  }

  Future<List<int>> getPageChainIds(int rootPageId) async {
    int pageId = rootPageId;

    final chainIds = <int>[];

    while (pageId != 0) {
      chainIds.add(pageId);
      final header = await readPageHeader(pageId);
      pageId = header.nextPageId;
    }

    return chainIds;
  }

  int _getPagePosition(int pageId) {
    return (pageId - 1) * pageSize + magicNumber.length;
  }
}
