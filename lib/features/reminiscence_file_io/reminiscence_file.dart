import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/footer.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/media_index_entry.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/page_header.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/page_type.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/metadata.dart';
import 'package:reminiscence/features/reminiscence_file_io/utils.dart';
import 'package:reminiscence/features/reminiscence_file_io/page_reader.dart';
import 'package:reminiscence/features/reminiscence_file_io/page_writer.dart';

class ReminiscenceFile {
  late String name;

  late RandomAccessFile _file;

  late PageReader _reader;
  late PageWriter _writer;
  late Metadata _metadata;
  late Footer _footer;

  Map<int, PageHeader> pageHeaderCache = {};

  ReminiscenceFile();

  void initializeReaderWriter() {
    /*
    Initialize the page reader and page writer after opening or creating the file.
    */
    _reader = PageReader(_file);
    _writer = PageWriter(_file, reader: _reader);

    _reader.initializePageHeaderCache(pageHeaderCache);
    _writer.initializePageHeaderCache(pageHeaderCache);
  }

  Future<void> initializeMetadata() async {
    /*
    Save the metadata in memory to access its the nonce, encrypted nonce, and the `IsEncrypted` flag easily.
    */
    _metadata = await _reader.readMetadata();
  }

  Future<void> initializeFooter() async {
    /*
    Save the footer in memory and provide the reader & writer the same instance of the footer so that modifications are shared.
    */
    _footer = await _reader.readFooter();
    _reader.initializeFooter(_footer);
    _writer.initializeFooter(_footer);
  }

  Future<void> open(String path) async {
    /*
    Open an existing file in append mode.
    */

    // Save the file path
    name = path;

    // Open the file
    _file = await File(path).open(mode: FileMode.append);

    // Prepare the page reader and page writer.
    initializeReaderWriter();

    // Make sure the magic number matches the expected magic number for our files.
    if (!(await validateMagicNumber())) {
      throw Exception("Invalid rem file. Magic number not recognized.");
    }

    // Load the metadata into memory.
    await initializeMetadata();

    // Load the footer into memory.
    await initializeFooter();
  }

  Future<void> create(
    String path, {
    Uint8List? nonce,
    Uint8List? encryptedNonce,
    bool isEncrypted = false,
  }) async {
    /*
    Create a new Reminiscence file or overwrite an existing one.
    */

    // Save the file path
    name = path;

    // Open the file in write mode
    _file = await File(path).open(mode: FileMode.write);

    // Prepare the page reader and page writer.
    initializeReaderWriter();

    // Write our magic number to the file.
    await _writer.writeMagicNumber();

    // Write the metadata page.
    await _writer.writeMetadata(
      Metadata(
        footerPageId: metadataPageId,
        nonce: nonce,
        encryptedNonce: encryptedNonce,
        isEncrypted: isEncrypted,
      ),
    );

    // Writer the footer page.
    await _writer.writeFooter(
      Footer(
        dbRootPageId: 0,
        mediaIndexRootPageId: 0,
        freeListRootPageId: 0,
        pageCount: 2,
      ),
    );

    // Load the metadata into memory.
    await initializeMetadata();

    // Load the footer into memory.
    await initializeFooter();
  }

  // `close()` writes the updated footer and then closes the file.
  Future<void> close() async {
    await _writer.writeFooter(_footer);
    await _file.close();
  }

  // Check if the file is encrypted.
  bool isEncrypted() => _metadata.isEncrypted;

  // Get the nonce as a `List<int>` (since that's what used by the `deriveKey` function)
  List<int> get nonce => _metadata.nonce.toList();

  // Get the encrypted nonce as a `List<int>` (since that's what used by the `decrypt` function)
  List<int> get encryptedNonce => _metadata.encryptedNonce.toList();

  Future<bool> validateMagicNumber() async {
    /*
    Check if the magic number of the file is correct (what is expected).
    */
    return (await _reader.readMagicNumber()) == magicNumber;
  }

  Future<void> addMediaFile(int attachmentId, File file) async {
    /*
    Add a media file to the rem file and to the media index.
    */

    // Get the page to start writing the media to.
    final watch = Stopwatch();
    watch.start();

    final mediaRootPageId = await _writer.getFreePage(PageType.media);
    //print("1. ${watch.elapsedMicroseconds} microseconds");

    // Prepare the media index entry with the media root page id and the attachment id.
    final mediaIndexEntry = MediaIndexEntry(
      attachmentId: attachmentId,
      mediaRootPageId: mediaRootPageId,
    );

    // Add the entry to the media index.
    //watch
    //  ..reset()
    //  ..start();
    await _writer.addToMediaIndex(mediaIndexEntry);
    //print("Added to media index in ${watch.elapsedMicroseconds} microseconds");

    // Write the data to this media file's cluster.
    //watch
    //  ..reset()
    //  ..start();
    await _writer.writeData(PageType.media, mediaRootPageId, file);
    //print("``writeData` Duration: ${watch.elapsedMilliseconds} ms");

    watch.stop();
  }

  Future<void> addMediaFileFromStream(
    int attachmentId,
    InputStream inputStream,
  ) async {
    /*
    Add a media file to the rem file and to the media index.
    */

    // Get the page to start writing the media to.
    final watch = Stopwatch();
    watch.start();

    final mediaRootPageId = await _writer.getFreePage(PageType.media);
    //print("1. ${watch.elapsedMicroseconds} microseconds");

    // Prepare the media index entry with the media root page id and the attachment id.
    final mediaIndexEntry = MediaIndexEntry(
      attachmentId: attachmentId,
      mediaRootPageId: mediaRootPageId,
    );

    // Add the entry to the media index.
    //watch
    //  ..reset()
    //  ..start();
    await _writer.addToMediaIndex(mediaIndexEntry);
    //print("Added to media index in ${watch.elapsedMicroseconds} microseconds");

    // Write the data to this media file's cluster.
    //watch
    //  ..reset()
    //  ..start();
    await _writer.writeDataFromStream(
      PageType.media,
      mediaRootPageId,
      inputStream,
    );
    //print("``writeData` Duration: ${watch.elapsedMilliseconds} ms");

    watch.stop();
  }

  Future<void> removeMediaFile(int attachmentId) async {
    /*
    Deletes a media file from the rem file and its entry from the media index.
    */

    // Get the media index entry for this attachment.
    final mediaIndexEntry = await _reader.readMediaIndexEntry(attachmentId);

    // if the entry was found, delete it.
    if (mediaIndexEntry.mediaRootPageId != 0) {
      // Remove the media file's index entry from the media index table by making its media pointer point nowhere (set mediaRootPageId to 0).
      mediaIndexEntry.mediaRootPageId = 0;
      await _writer.addToMediaIndex(mediaIndexEntry);
    }
  }

  Future<void> writeDatabase(File dbFile) => _writer.writeDatabase(dbFile);

  Future<void> readDatabaseToFile(File outputFile) async {
    /*
    Reads the database file within the rem file and writes it to `outputFile`.
    */
    final rootId = _footer.dbRootPageId;
    await _readToFile(rootId, outputFile);
  }

  Future<void> readMediaIndex() => _reader.readMediaIndex();

  Future<void> readMediaToFile(int attachmentId, File outputFile) async {
    /*
    Reads the media file related to `attachmentId` stored within the rem file and writes it to `outputFile`.
    */

    print("Locating attachment $attachmentId media index entry.");

    final mediaIndexEntry = await _reader.readMediaIndexEntry(attachmentId);

    print(
      "Writing attachment $attachmentId to file from page ${mediaIndexEntry.mediaRootPageId}.",
    );

    await _readToFile(mediaIndexEntry.mediaRootPageId, outputFile);

    print("Finished writing attachment $attachmentId");
  }

  Future<void> _readToFile(int rootPageId, File outputFile) async {
    /*
    Read the data within a cluster to a file.
    */

    final sink = outputFile.openWrite();

    await for (final buffer in _reader.readData(rootPageId)) {
      sink.add(buffer);
    }

    await sink.flush();
    await sink.close();
  }
}
