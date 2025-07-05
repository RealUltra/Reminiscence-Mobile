import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:reminiscence/features/reminiscence_file_io/components/footer.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/media_index_entry.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/media_index_table.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/metadata.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/page.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/page_header.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/utils.dart';

class PageReader {
  final RandomAccessFile file;

  late final Footer _footer;

  PageReader(this.file);

  void initializeFooter(Footer footer) {
    /*
    Save the footer in memory.
    */
    _footer = footer;
  }

  Future<String> readMagicNumber() async {
    /*
    Reads the magic number stored within the file.
    */
    await file.setPosition(0);
    final magic = String.fromCharCodes(await file.read(magicNumber.length));
    return magic;
  }

  Future<Metadata> readMetadata() async {
    /*
    Read the metadata of this file.
    */
    final page = await readPage(metadataPageId);
    return Metadata.fromBytes(page.payload);
  }

  Future<Footer> readFooter() async {
    /*
    Reads the footer page.
    */
    final page = await readPage(footerPageId);
    return Footer.fromBytes(page.payload);
  }

  Future<PageHeader> readPageHeader(int pageId) async {
    /*
    Read the page header of a particular page.
    */
    final position = getPagePosition(pageId);
    await file.setPosition(position);
    final pageHeader = PageHeader.fromBytes(await file.read(pageHeaderSize));
    return pageHeader;
  }

  Future<Page> readPage(int pageId) async {
    /*
    Reads the header and payload of a single page.
    */

    // Read the page header to know the payload size
    final pageHeader = await readPageHeader(pageId);

    // The `readPageHeader()` function already moved the pointer to the correct position for this.
    final payload = await file.read(pageHeader.payloadSize);

    // Return the page with the header and the payload.
    return Page(header: pageHeader, payload: payload);
  }

  Stream<Uint8List> readData(int rootPageId) async* {
    /*
    Read data from a cluster starting from `rootPageId`.

    Stream the data out in chunks instead of returning it altogether for better memory management.
    */

    int pageId = rootPageId;

    while (pageId != 0) {
      final page = await readPage(pageId);
      yield page.payload.sublist(0, page.header.payloadSize);
      pageId = page.header.nextPageId;
    }
  }

  Future<Uint8List> readAtOffset(int rootPageId, int offset, int length) async {
    /*
    Reads a certain length of data from a cluster at a particular offset.
    */

    // Calculate the index of the page you must start reading from.
    final targetPageIndex = (offset / maxPayloadSize).toInt();

    // Get the cluster.
    final cluster = await getCluster(rootPageId);

    // If the cluster doesn't reach the target page, return an empty byte list.
    if (cluster.length <= targetPageIndex) {
      return Uint8List(length);
    }

    // Get the id of the page you must start reading form.
    final targetPageId = cluster[targetPageIndex];

    // Calculate the offset from the start of this page, or the "relative" offset.
    final relativeOffset = offset % maxPayloadSize;

    // Calculate how many bytes we can possibly read, based on the the position we are reading from and the capacity of any page.
    final readLimit = maxPayloadSize - relativeOffset;

    // Move beyond the page's header and the offset.
    final position = getPagePosition(targetPageId);
    await file.setPosition(position + pageHeaderSize + relativeOffset);

    // Read as many bytes as you can, with a maximum of `readLimit`.
    final bytes = await file.read(min(readLimit, length));

    // Use the sized payload to pad the payload with 0s if the readLimit is below the desired length.
    final sizedPayload = Uint8List(length);
    sizedPayload.setAll(0, bytes);

    // If the read limit was below the length and the cluster has another page after this one, read the remaining bytes from it.
    if (readLimit < length && cluster.length > (targetPageIndex + 1)) {
      final nextPageId = cluster[targetPageIndex + 1];
      final bytes = await readAtOffset(nextPageId, 0, length - readLimit);
      sizedPayload.setAll(readLimit, bytes);
    }

    // Return the payload that was read.
    return sizedPayload;
  }

  Future<MediaIndexTable> readMediaIndex() async {
    /*
    Read the entire media index table.
    */

    // Read it from the stream and store it in a dynamically sized list.
    List<int> payload = [];

    await for (final buffer in readData(_footer.mediaIndexRootPageId)) {
      payload.addAll(buffer);
    }

    // Convert the List<int> into a Uint8List of fixed size and interpret the media index table from those bytes.
    return MediaIndexTable.fromBytes(Uint8List.fromList(payload));
  }

  Future<MediaIndexEntry> readMediaIndexEntry(int attachmentId) async {
    /*
    Reads a particular media index entry based on its attachment id.
    */

    // If the media index table is empty, return a blank media index entry.
    if (_footer.mediaIndexRootPageId == 0) {
      return MediaIndexEntry.fromBytes(Uint8List(mediaIndexEntrySize));
    }

    // Calculate the entry's position within the media index table
    final offset = attachmentId * mediaIndexEntrySize;

    // Read at that position from the start of the media index.
    final bytes = await readAtOffset(
      _footer.mediaIndexRootPageId,
      offset,
      mediaIndexEntrySize,
    );

    // Return the media index entry that was read.
    return MediaIndexEntry.fromBytes(bytes);
  }

  Future<List<int>> getCluster(int rootPageId) async {
    /*
    Get the id of every page in a cluster, starting from `rootPageId`.

    Cluster: A cluster is defined as a linked list of connected pages.
    */

    int pageId = rootPageId;
    final clusterIds = <int>[];

    while (pageId != 0) {
      clusterIds.add(pageId);
      final header = await readPageHeader(pageId);
      pageId = header.nextPageId;
    }

    return clusterIds;
  }
}
