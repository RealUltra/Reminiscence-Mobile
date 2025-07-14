import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/footer.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/media_index_entry.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/metadata.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/page.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/page_header.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/page_type.dart';
import 'package:reminiscence/features/reminiscence_file_io/utils.dart';
import 'package:reminiscence/features/reminiscence_file_io/page_reader.dart';

class PageWriter {
  final RandomAccessFile file;

  final PageReader reader;
  late final Footer _footer;

  // A cache storing page ids and their headers.
  // Key: page id
  // Value: its page header
  late final Map<int, PageHeader> _pageHeaderCache;

  PageWriter(this.file, {required this.reader});

  void initializeFooter(Footer footer) {
    /*
    Save the footer in memory.
    */
    _footer = footer;
  }

  void initializePageHeaderCache(Map<int, PageHeader> pageHeaderCache) {
    /*
    Save the footer in memory.
    */
    _pageHeaderCache = pageHeaderCache;
  }

  Future<void> writeMagicNumber() async {
    /*
    Moves the position to the beginning of the file and writes our magic number there.
    */
    await file.setPosition(0);
    await file.writeFrom(Uint8List.fromList(utf8.encode(magicNumber)));
  }

  Future<void> writePageHeader(PageHeader pageHeader) async {
    /*
    Purpose: Writes a page header to a particular page id.

    Calculates the position of the page based on its id.
    Moves to that position.
    Writes the page header.
    */
    final pageId = pageHeader.pageId;
    final position = getPagePosition(pageId);
    await file.setPosition(position);
    await file.writeFrom(pageHeader.toBytes());
    _pageHeaderCache[pageId] = pageHeader;
  }

  Future<int> writePage(Page page) async {
    /*
    `writePage` can write data to a page, overwriting existing data.

    A payload longer than what a page can fit will be recursively passed to the next page.

    Returns the page id of the last page it wrote to.
    */

    // Constrain the payload size to have a maximum of `maximumPayloadSize`.
    final payloadSize = min(maxPayloadSize, page.payload.length);

    // Set the constrained payload size in the page header
    page.header.payloadSize = payloadSize;

    // If there is any data remaining after the page is filled, that will be written to the next page.
    if (page.payload.length > maxPayloadSize) {
      final nextPageId = await getFreePage();
      page.header.nextPageId = nextPageId;
    } else {
      page.header.nextPageId = 0;
    }

    // Pad the rest of the page with 0s if the payload is less than `maxPayloadSize`.
    final sizedPayload = Uint8List(maxPayloadSize);
    sizedPayload.setAll(0, Uint8List.sublistView(page.payload, 0, payloadSize));

    // Write the page header, which will also move the file cursor to the target page.
    await writePageHeader(page.header);

    // Write the payload
    await file.writeFrom(sizedPayload);

    // Write the next page
    if (page.header.nextPageId != 0) {
      // Return whatever id this returns, because that will be where it stopped writing.
      return await writePage(
        Page(
          header: PageHeader(
            pageType: page.header.pageType,
            pageId: page.header.nextPageId,
          ),

          payload: Uint8List.sublistView(page.payload, maxPayloadSize),
        ),
      );
    }

    // Return this page as the function stopped writing here.
    return page.header.pageId;
  }

  Future<int> appendToPage(
    PageType pageType,
    int pageId,
    Uint8List payload,
  ) async {
    /*
    `appendToPage` can add a payload to a page (or cluster) without overwriting the existing data.

    Returns the page id of the page containing the end of the payload.
    */

    // Get the last page in the cluster.
    final cluster = await reader.getCluster(pageId);
    final lastPageId = cluster.last;

    // Get the offset at which you must start writing.
    final pageHeader = await _getPageHeader(lastPageId);
    final offset = pageHeader.payloadSize;

    // Calculate the remaining capacity of this page.
    final pageCapacity = maxPayloadSize - offset;

    // If the page is not at maximum capacity, write to it.
    if (pageCapacity > 0) {
      // The sized payload ensures that the payload is not larger than the page capacity.
      final sizedPayload = Uint8List.sublistView(
        payload,
        0,
        min(pageCapacity, payload.length),
      );

      // This is the remaining payload after the sized payload is written to this page.
      payload = Uint8List.sublistView(payload, sizedPayload.length);

      // Set the position to beyond the page's header & current payload.
      final position = getPagePosition(lastPageId);
      await file.setPosition(position + pageHeaderSize + offset);

      // Write the sized payload to the page.
      await file.writeFrom(sizedPayload);

      // Update the page header's payload size.
      pageHeader.payloadSize += sizedPayload.length;
    }

    // If there is no payload remaining, write the header (to update the payload size) and end the function.
    if (payload.isEmpty) {
      await writePageHeader(pageHeader);
      return pageHeader.pageId;
    }

    // If the payload is not empty, write the next page's id to the page header.
    pageHeader.nextPageId = await getFreePage(pageType);

    await writePageHeader(pageHeader);

    // Write the next page and return whatever it returns, because that will be where it stopped writing.
    final result = await writePage(
      Page(
        header: PageHeader(pageType: pageType, pageId: pageHeader.nextPageId),
        payload: payload,
      ),
    );

    return result;
  }

  Future<void> writeAtOffset(
    PageType pageType,
    int rootPageId,
    int offset,
    Uint8List payload,
  ) async {
    /*
    Writes to a cluster at a given offset.

    Pages that the offset skips get set to maximum capacity, but no data is overwritten.
    This means that any existing data stays, and any empty portions are left as 0s now considered part of the payload.
    */

    // Get the cluster to skip to the appropriate page as per the offset
    final cluster = await reader.getCluster(rootPageId);

    // Calculate the index in the cluster of the page that will be written to.
    final targetPageIndex = (offset / maxPayloadSize).toInt();

    // If the target page does not exist, keep adding pages to the cluster until it does.
    while (cluster.length <= targetPageIndex) {
      // Set the size of the cluster's last page to maximum.
      // This is because we don't want the targetPageIndex to simulate any data, but we do want every other page to simulate being full.
      final header = await _getPageHeader(cluster.last);
      header.payloadSize = maxPayloadSize;
      await writePageHeader(header);

      // Add a new page to the cluster and to the local cluster array (to avoid refetching each time).
      final pageId = await addToCluster(pageType, cluster.last);
      cluster.add(pageId);
    }

    // Get the id of the page you have to write to.
    final targetPageId = cluster[targetPageIndex];

    // Calculate the offset on only the target page, the "relative" offset.
    final relativeOffset = offset % maxPayloadSize;

    // Read the page header to know how much data is already written to it.
    final pageHeader = await _getPageHeader(targetPageId);

    // Calculate the page's capacity from the position we will be writing to.
    final pageCapacity = maxPayloadSize - relativeOffset;

    // The sized payload ensures that the payload does not overflow beyond the page's capacity.
    final sizedPayload = Uint8List(min(pageCapacity, payload.length));
    sizedPayload.setAll(
      0,
      Uint8List.sublistView(payload, 0, sizedPayload.length),
    );

    // Prepare the remaining payload to write to the next page.
    final remainingPayload = Uint8List.sublistView(
      payload,
      sizedPayload.length,
    );

    // If there is space on the page, write the payload.
    if (sizedPayload.isNotEmpty) {
      // Write the payload.
      final position = getPagePosition(targetPageId);
      await file.setPosition(position + pageHeaderSize + relativeOffset);
      await file.writeFrom(sizedPayload);

      // Update the page header's payload size if it doesn't already encompass the data we just wrote.
      final endOfPayload = offset + sizedPayload.length;

      if (pageHeader.payloadSize < endOfPayload) {
        pageHeader.payloadSize += endOfPayload;
        await writePageHeader(pageHeader);
      }
    }

    // If there is data remaining, write it to the next page.
    if (remainingPayload.isNotEmpty) {
      // if the page has no next page, simply append the remaining data to the existing cluster.
      if (pageHeader.nextPageId == 0) {
        await appendToPage(pageType, targetPageId, remainingPayload);
      }
      // If the page has a page after it, we use `writeAtOffset` because we are trying to overwrite the starting bytes of that page, not append data to it.
      else {
        await writeAtOffset(
          pageType,
          pageHeader.nextPageId,
          0,
          remainingPayload,
        );
      }
    }
  }

  Future<int> writeData(PageType pageType, int rootPageId, File file) async {
    /*
    Write data from a stream into a cluster.

    Returns the page id of the last page it wrote to.
    */

    // Open the file and prepare to read it.
    final raf = await file.open();
    final fileLength = await raf.length();
    int offset = 0;

    return _writeData(pageType, rootPageId, (int chunkSize) async {
      // Determine the chunk size. It cannot be larger than the number of bytes remaining.
      final remaining = fileLength - offset;
      final currentChunkSize = remaining >= chunkSize ? chunkSize : remaining;

      // Read the chunk
      final chunk = await raf.read(currentChunkSize);

      offset += currentChunkSize;

      return chunk;
    }, () => (offset >= fileLength));
  }

  Future<int> writeDataFromStream(
    PageType pageType,
    int rootPageId,
    Stream<List<int>> stream,
  ) async {
    /*
    Write data from a stream into a cluster.

    Returns the page id of the last page it wrote to.
    */

    final iterator = StreamIterator(stream);
    bool finished = await iterator.moveNext();

    return _writeData(pageType, rootPageId, (int chunkSize) async {
      // Determine the chunk size. It cannot be larger than the number of bytes remaining.
      final chunk = iterator.current;
      finished = !(await iterator.moveNext());
      return Uint8List.fromList(chunk);
    }, () => finished);
  }

  Future<int> writeDataFromInputStream(
    PageType pageType,
    int rootPageId,
    InputStream inputStream,
  ) async {
    /*
    Write data from a stream into a cluster.

    Returns the page id of the last page it wrote to.
    */

    // Open the file and prepare to read it.
    final fileLength = inputStream.length;
    int offset = 0;
    Uint8List? chunk;

    return _writeData(pageType, rootPageId, (int chunkSize) async {
      chunk ??= Uint8List(chunkSize);

      final remaining = fileLength - offset;
      final currentChunkSize = remaining >= chunkSize ? chunkSize : remaining;

      final chunkStream = inputStream.readBytes(currentChunkSize);

      for (int i = 0; i < currentChunkSize; i++) {
        chunk![i] = chunkStream.readUint8();
      }

      offset += currentChunkSize;

      return Uint8List.sublistView(chunk!, 0, currentChunkSize);
    }, () => (offset >= fileLength));
  }

  Future<int> _writeData(
    PageType pageType,
    int rootPageId,
    Future<Uint8List> Function(int chunkSize) getNextChunk,
    bool Function() endOfFile,
  ) async {
    /*
    Write data as chunks into a cluster. Used to write data from a file, an `InputFileStream` or a `Stream<List<int>>`.

    Returns the page id of the last page it wrote to.
    */

    // Add the existing cluster to the free list to remove any existing data.
    final pageHeader = await _getPageHeader(rootPageId);

    // Remove any existing data from the root page as well by emptying it.
    await writePage(
      Page(header: PageHeader(pageType: pageType, pageId: rootPageId)),
    );

    if (pageHeader.nextPageId != 0) {
      await addToFreeList(pageHeader.nextPageId);
    }

    // Get chunks from the stream and append them to the root page.
    int pageId = rootPageId;

    // Open the file and prepare to read it.
    final chunkSize = maxPayloadSize;

    while (!endOfFile()) {
      // Determine the chunk size. It cannot be larger than the number of bytes remaining.
      final chunk = await getNextChunk(chunkSize);

      // Keep track of the last page the function wrote to so that it doesn't have to traverse the entire cluster each time.
      pageId = await appendToPage(pageType, pageId, chunk);
    }

    // Return the final page id as it is the last one written to.
    return pageId;
  }

  Future<void> writeMetadata(Metadata metadata) async {
    /*
    Write some metadata to the footer page.
    */
    await writePage(
      Page(
        header: PageHeader(pageType: PageType.metadata, pageId: 1),
        payload: metadata.toBytes(),
      ),
    );
  }

  Future<void> writeFooter(Footer footer) async {
    /*
    Write some footer data to the footer page.
    */
    await writePage(
      Page(
        header: PageHeader(pageType: PageType.footer, pageId: footerPageId),
        payload: footer.toBytes(),
      ),
    );
  }

  Future<void> writeDatabase(File dbFile) async {
    /*
    Write a database file to the database segment of the rem file.
    */
    await ensureDatabaseInitialized();
    await writeData(PageType.database, _footer.dbRootPageId, dbFile);
  }

  Future<void> addToMediaIndex(MediaIndexEntry entry) async {
    /*
    Add a new entry to the media index table.
    */

    // Read the existing entry of this attachment in the media index table to delete any existing media.
    final mediaIndexEntry = await reader.readMediaIndexEntry(
      entry.attachmentId,
    );

    // If the entry exists, delete its data (by adding it to the free list).
    if (mediaIndexEntry.mediaRootPageId != 0) {
      await addToFreeList(mediaIndexEntry.mediaRootPageId);
    }

    // Calculate the position within the media index table's cluster where the entry must be written to.
    final offset = entry.attachmentId * mediaIndexEntrySize;

    // Make sure the media index has at least one page allocated to it.
    await ensureMediaIndexInitialized();

    // Write the entry to the media index table at the correct position.
    await writeAtOffset(
      PageType.mediaIndex,
      _footer.mediaIndexRootPageId,
      offset,
      entry.toBytes(),
    );
  }

  Future<void> addToFreeList(int rootPageId) async {
    /*
    Adds an existing cluster to the free list.
    */

    // Update the header of each page in the cluster to make each of them a free page.
    final cluster = await reader.getCluster(rootPageId);

    for (int i = 0; i < cluster.length; i++) {
      final pageId = cluster[i];
      final nextPageId = (i == cluster.length - 1) ? 0 : cluster[i + 1];

      await writePageHeader(
        PageHeader(
          pageType: PageType.free,
          pageId: pageId,
          nextPageId: nextPageId,
        ),
      );
    }

    // Update the next pointer of the last member of the free list, adding this cluster to the end of the free list.
    final freeList = await reader.getCluster(_footer.freeListRootPageId);

    await writePageHeader(
      PageHeader(
        pageType: PageType.free,
        pageId: freeList.last,
        nextPageId: rootPageId,
      ),
    );

    // As pages were just added to the free list, there may now be free pages at the end of the file. Remove them.
    await garbageCollector();
  }

  Future<void> garbageCollector() async {
    /*
    Truncates any trailing free pages in the file to reduce the file size.
    */

    // Get the free list to inspect it.
    final freeList = await reader.getCluster(_footer.freeListRootPageId);

    // Get the last page id in the file using the footer.
    final lastPageId = _footer.pageCount;

    // If the free list contains the very last page of the file, delete it from the file entirely.
    if (freeList.contains(lastPageId)) {
      // Optional logging for the garbage collector.
      //print("[Garbage Collector] Removing Page $lastPageId");

      // Remove the last page from the file.
      final position = getPagePosition(lastPageId);
      await file.truncate(position);

      // Get the position in the free list of the last page so that you may determine what next pointers you must modify.
      final index = freeList.indexOf(lastPageId);

      // If the last page is the free list's root page, update the root page id in the footer.
      if (index == 0) {
        // If the free list has no other pages besides this one, set the free list root page id to 0.
        final nextRootPageId = freeList.length > 1 ? freeList[1] : 0;
        _footer.freeListRootPageId = nextRootPageId;
      }
      // If it is any other page, modify the next pointer of the page before it to connect it to the page after it.
      else {
        // Read the page header of the previous page to modify it.
        final pageHeader = await _getPageHeader(freeList[index - 1]);

        // If there is a page in the free list after this page, the previous page will point to it. Otherwise, the previous page will point nowhere (nextPageId = 0)
        pageHeader.nextPageId =
            freeList.length > (index + 1) ? freeList[index + 1] : 0;

        // Write the updated page header.
        await writePageHeader(pageHeader);
      }

      // Indicate the page deletion, and possibly the new free list root page, within the footer.
      _footer.pageCount--;

      // Call the garbage collector again in case the free list contains more pages at the end of the file.
      await garbageCollector();
    }
  }

  Future<int> addToCluster(PageType pageType, int rootPageId) async {
    /*
    Add a new page to the end of an existing cluster, then return its id.
    */

    // Create a new page.
    final newPageId = await getFreePage(pageType);

    // Get the existing cluster.
    final cluster = await reader.getCluster(rootPageId);

    // If the cluster isn't empty, update its last page to point towards the new page (thus adding it to the cluster).
    if (cluster.isNotEmpty) {
      final lastPageId = cluster.last;
      final lastPageHeader = await _getPageHeader(lastPageId);
      lastPageHeader.nextPageId = newPageId;
      await writePageHeader(lastPageHeader);
    }

    // Return the new page's id.
    return newPageId;
  }

  Future<int> getFreePage([PageType pageType = PageType.free]) async {
    /*
    Fetches a free page from the free list and sometimes initializes a new free page to take its place.

    Used to get an empty page to write data to.
    */

    // Make sure at least a single free page exists within the file.
    await ensureFreePageInitialized();

    // Get the first free page's id (The free page that will be returned)
    final freePageId = _footer.freeListRootPageId;

    // Get the first free page's header so that you may set the page fater it as the new root free page.
    final freePageHeader = await _getPageHeader(freePageId);

    // Prepare the free page you will return by making sure it is a fully filled page, changing the page type and ensuring it has no page after it.

    await writePage(
      Page(header: PageHeader(pageType: pageType, pageId: freePageId)),
    );

    // If this free page had a page after it, make it the next root free page. Otherwise, create a new free page to set as the root.
    if (freePageHeader.nextPageId != 0) {
      _footer.freeListRootPageId = freePageHeader.nextPageId;
    } else {
      _footer.freeListRootPageId = await _newFreePage();
    }

    // Return the free page.
    return freePageId;
  }

  Future<int> _newFreePage() async {
    /*
    Create a new free page at the end of the file.
    */
    final pageId = ++_footer.pageCount;
    await writePageHeader(PageHeader(pageType: PageType.free, pageId: pageId));
    return pageId;
  }

  Future<PageHeader> _getPageHeader(int pageId) async {
    if (_pageHeaderCache.containsKey(pageId)) {
      return _pageHeaderCache[pageId]!;
    }

    final pageHeader = await reader.readPageHeader(pageId);
    _pageHeaderCache[pageId] = pageHeader;

    return pageHeader;
  }

  Future<void> ensureDatabaseInitialized() async {
    /*
    Ensures that the database root page id stored within the footer is not 0.
    */
    if (_footer.dbRootPageId == 0) {
      _footer.dbRootPageId = await getFreePage(PageType.database);
    }
  }

  Future<void> ensureMediaIndexInitialized() async {
    /*
    Ensures that the media index root page id stored within the footer is not 0.
    */
    if (_footer.mediaIndexRootPageId == 0) {
      _footer.mediaIndexRootPageId = await getFreePage(PageType.mediaIndex);
    }
  }

  Future<void> ensureFreePageInitialized() async {
    /*
    Ensures that the free list root page id stored within the footer is not 0.
    */
    if (_footer.freeListRootPageId == 0) {
      _footer.freeListRootPageId = await _newFreePage();
    }
  }
}
