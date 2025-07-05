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
  late Footer footer;

  ReminiscenceFile();

  Future<void> open(String path) async {
    _file = await File(path).open(mode: FileMode.append);

    if (!(await validateMagicNumber())) {
      throw Exception("Invalid rem file. Magic number not recognized.");
    }

    footer = await readFooter();
  }

  Future<void> create(String path) async {
    _file = await File(path).open(mode: FileMode.write);

    await writeMagicNumber();

    // Metadata page
    await writeMetadata(Metadata(footerPageId: 2));

    // Footer
    await writeFooter(
      Footer(
        dbRootPageId: 0,
        mediaIndexRootPageId: 0,
        freeListRootPageId: 0,
        pageCount: 2,
      ),
    );

    footer = await readFooter();
  }

  Future<void> close() => _file.close();

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
      final nextPageId = await getFreePage();

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

    final offset = pageHeader.payloadSize;
    final position = _getPagePosition(lastPageId);

    final pageCapacity = maxPayloadSize - offset;

    if (pageCapacity > 0) {
      await _file.setPosition(position + pageHeaderSize + offset);

      final sizedPayload = payload.sublist(
        0,
        min(pageCapacity, payload.length),
      );
      payload = payload.sublist(sizedPayload.length);

      await _file.writeFrom(sizedPayload);

      pageHeader.payloadSize += sizedPayload.length;
    }

    if (payload.isEmpty) {
      await writePageHeader(pageHeader);
      return;
    }

    pageHeader.nextPageId = await getFreePage();
    await writePageHeader(pageHeader);

    await writePage(
      PageHeader(pageType: pageType, pageId: pageHeader.nextPageId),
      payload,
    );
  }

  Future<void> writeAtOffset(
    PageType pageType,
    int rootPageId,
    int offset,
    Uint8List payload,
  ) async {
    int bytesTraversed = 0;
    int pageId = rootPageId;

    while (bytesTraversed < offset) {
      final pageHeader = await readPageHeader(pageId);
      final bytesRemaining = offset - bytesTraversed;

      if (bytesRemaining > maxPayloadSize) {
        bytesTraversed += maxPayloadSize;

        if (pageHeader.nextPageId == 0) {
          pageHeader.nextPageId = await getFreePage();
        }

        pageHeader.pageType = pageType;
        await writePageHeader(pageHeader);

        pageId = pageHeader.nextPageId;
      } else {
        bytesTraversed += bytesRemaining;
      }
    }

    final pageHeader = await readPageHeader(pageId);

    final actualPayloadSize = pageHeader.payloadSize;
    final tempPayloadSize = offset % maxPayloadSize;

    pageHeader.payloadSize = tempPayloadSize;
    await writePageHeader(pageHeader);

    await appendToPage(pageType, pageId, payload);

    pageHeader.payloadSize = max(
      actualPayloadSize,
      min(maxPayloadSize, tempPayloadSize + payload.length),
    );
    await writePageHeader(pageHeader);
  }

  Future<void> writePayload(
    PageType pageType,
    int rootPageId,
    Stream<List<int>> stream,
  ) async {
    final pageHeader = await readPageHeader(rootPageId);

    if (pageHeader.nextPageId != 0) {
      await addToFreeList(pageHeader.nextPageId);
    }

    await for (final bytes in stream) {
      await appendToPage(pageType, rootPageId, Uint8List.fromList(bytes));
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
      PageHeader(pageType: PageType.footer, pageId: 2),
      footer.toBytes(),
    );
  }

  Future<void> writeDatabase(File dbFile) async {
    if (footer.dbRootPageId == 0) {
      footer.dbRootPageId = await getFreePage();
      await writeFooter(footer);
    }

    final rootId = footer.dbRootPageId;
    await writePayload(PageType.database, rootId, dbFile.openRead());
  }

  Future<void> addToMediaIndex(MediaIndexEntry entry) async {
    if (footer.mediaIndexRootPageId == 0) {
      footer.mediaIndexRootPageId = await getFreePage();
      await writeFooter(footer);
    }

    final mediaIndexEntry = await readMediaIndexEntry(entry.attachmentId);

    if (mediaIndexEntry.mediaRootPageId != 0) {
      print(
        "Media Root Page Causing The Error: ${mediaIndexEntry.mediaRootPageId}",
      );
      await addToFreeList(mediaIndexEntry.mediaRootPageId);
    }

    final rootId = footer.mediaIndexRootPageId;
    final offset = entry.attachmentId * mediaIndexEntrySize;

    await writeAtOffset(PageType.mediaIndex, rootId, offset, entry.toBytes());
  }

  Future<void> addMediaFile(int attachmentId, File file) async {
    final mediaRootPageId = await getFreePage();

    final mediaIndexEntry = MediaIndexEntry(
      attachmentId: attachmentId,
      mediaRootPageId: mediaRootPageId,
    );

    await addToMediaIndex(mediaIndexEntry);

    await writePayload(PageType.media, mediaRootPageId, file.openRead());
  }

  Future<void> addToFreeList(int rootPageId) async {
    final chainIds = await getPageChainIds(rootPageId);

    for (int i = 0; i < chainIds.length; i++) {
      final pageId = chainIds[i];
      final nextPageId = (i == chainIds.length - 1) ? 0 : chainIds[i + 1];

      await writePage(
        PageHeader(
          pageType: PageType.free,
          pageId: pageId,
          nextPageId: nextPageId,
        ),
        Uint8List(0),
      );
    }

    final freeList = await getPageChainIds(footer.freeListRootPageId);

    await writePageHeader(
      PageHeader(
        pageType: PageType.free,
        pageId: freeList.last,
        nextPageId: rootPageId,
      ),
    );

    await removeTrailingFreePages();
  }

  Future<void> removeTrailingFreePages() async {
    final freeList = await getPageChainIds(footer.freeListRootPageId);

    final lastPageId = footer.pageCount;

    if (freeList.length > 1 && freeList.contains(lastPageId)) {
      final index = freeList.indexOf(lastPageId);

      if (index == 0) {
        footer.freeListRootPageId = freeList[1];
        await writeFooter(footer);
      } else {
        final pageHeader = await readPageHeader(freeList[index - 1]);
        pageHeader.nextPageId = 0;
        await writePageHeader(pageHeader);
      }

      final position = _getPagePosition(lastPageId);
      await _file.truncate(position);

      footer.pageCount--;
      await writeFooter(footer);

      await removeTrailingFreePages();
    }
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

  Future<Uint8List> readAtOffset(int rootPageId, int offset, int length) async {
    final chainIds = await getPageChainIds(rootPageId);

    if (chainIds.isEmpty) {
      return Uint8List(length);
    }

    final lastPageHeader = await readPageHeader(chainIds.last);
    final totalPayloadSize =
        (chainIds.length - 1) * maxPayloadSize + lastPageHeader.payloadSize;

    if (totalPayloadSize < (offset + length)) {
      return Uint8List(length);
    }

    int bytesTraversed = 0;
    int pageId = chainIds.first;

    for (pageId in chainIds) {
      final header = await readPageHeader(pageId);
      bytesTraversed += header.payloadSize;

      if (bytesTraversed >= offset) {
        break;
      }
    }

    final position = _getPagePosition(pageId);
    final relativeOffset = offset % maxPayloadSize;
    await _file.setPosition(position + pageHeaderSize + relativeOffset);

    final payload = await _file.read(length);

    final sizedPayload = Uint8List(length);
    sizedPayload.setAll(0, payload);

    return sizedPayload;
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
    final page = await readPage(2);
    return Footer.fromBytes(page.payload);
  }

  Future<void> readDatabaseToFile(File outputFile) async {
    final rootId = footer.dbRootPageId;
    await readPayloadToFile(rootId, outputFile);
  }

  Future<MediaIndexTable> readMediaIndex() async {
    final rootId = footer.mediaIndexRootPageId;

    List<int> payload = [];

    await for (final buffer in readPayload(rootId)) {
      payload.addAll(buffer);
    }

    return MediaIndexTable.fromBytes(Uint8List.fromList(payload));
  }

  Future<MediaIndexEntry> readMediaIndexEntry(int attachmentId) async {
    final rootId = footer.mediaIndexRootPageId;

    if (rootId == 0) {
      return MediaIndexEntry.fromBytes(Uint8List(mediaIndexEntrySize));
    }

    final offset = attachmentId * mediaIndexEntrySize;

    final bytes = await readAtOffset(rootId, offset, mediaIndexEntrySize);

    return MediaIndexEntry.fromBytes(bytes);
  }

  Future<void> readMediaToFile(int attachmentId, File outputFile) async {
    final mediaIndexEntry = await readMediaIndexEntry(attachmentId);
    await readPayloadToFile(mediaIndexEntry.mediaRootPageId, outputFile);
  }

  Future<int> getFreePage() async {
    if (footer.freeListRootPageId == 0) {
      footer.pageCount++;
      footer.freeListRootPageId = footer.pageCount;

      await writeFooter(footer);

      await writePageHeader(
        PageHeader(pageType: PageType.free, pageId: footer.freeListRootPageId),
      );
    }

    final freePageId = footer.freeListRootPageId;
    final freePageHeader = await readPageHeader(freePageId);

    int nextFreePageId;

    if (freePageHeader.nextPageId != 0) {
      nextFreePageId = freePageHeader.nextPageId;
    } else {
      footer.pageCount++;
      nextFreePageId = footer.pageCount;

      await writeFooter(footer);

      await writePageHeader(
        PageHeader(pageType: PageType.free, pageId: nextFreePageId),
      );
    }

    footer.freeListRootPageId = nextFreePageId;

    await writeFooter(footer);

    await writePageHeader(
      PageHeader(pageType: PageType.free, pageId: freePageId),
    );

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
