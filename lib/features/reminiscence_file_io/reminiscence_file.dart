import 'dart:io';

import 'package:reminiscence/features/reminiscence_file_io/components/footer.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/media_index_entry.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/page_type.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/metadata.dart';
import 'package:reminiscence/features/reminiscence_file_io/components/utils.dart';
import 'package:reminiscence/features/reminiscence_file_io/page_reader.dart';
import 'package:reminiscence/features/reminiscence_file_io/page_writer.dart';

class ReminiscenceFile {
  late RandomAccessFile _file;

  late PageReader _reader;
  late PageWriter _writer;
  late Footer _footer;

  ReminiscenceFile();

  void initializeReaderWriter() {
    /*
    Initialize the page reader and page writer after opening or creating the file.
    */
    _reader = PageReader(_file);
    _writer = PageWriter(_file, reader: _reader);
  }

  Future<void> initializeFooter() async {
    /*
    Save the footer in memory and provider the reader & writer the same instance of the footer so that modifications are shared.
    */
    _footer = await _reader.readFooter();
    _reader.initializeFooter(_footer);
    _writer.initializeFooter(_footer);
  }

  Future<void> open(String path) async {
    /*
    Open an existing file in append mode.
    */

    // Open the file
    _file = await File(path).open(mode: FileMode.append);

    // Prepare the page reader and page writer.
    initializeReaderWriter();

    // Make sure the magic number matches the expected magic number for our files.
    if (!(await validateMagicNumber())) {
      throw Exception("Invalid rem file. Magic number not recognized.");
    }

    // Load the footer into memory.
    await initializeFooter();
  }

  Future<void> create(String path) async {
    /*
    Create a new Reminiscence file or overwrite an existing one.
    */

    // Open the file in write mode
    _file = await File(path).open(mode: FileMode.write);

    // Prepare the page reader and page writer.
    initializeReaderWriter();

    // Write our magic number to the file.
    await _writer.writeMagicNumber();

    // Write the metadata page.
    await _writer.writeMetadata(Metadata(footerPageId: metadataPageId));

    // Writer the footer page.
    await _writer.writeFooter(
      Footer(
        dbRootPageId: 0,
        mediaIndexRootPageId: 0,
        freeListRootPageId: 0,
        pageCount: 2,
      ),
    );

    // Load the footer into memory.
    await initializeFooter();
  }

  // `close()` simply closes the file.
  Future<void> close() => _file.close();

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
    final mediaRootPageId = await _writer.getFreePage();

    // Prepare the media index entry with the media root page id and the attachment id.
    final mediaIndexEntry = MediaIndexEntry(
      attachmentId: attachmentId,
      mediaRootPageId: mediaRootPageId,
    );

    // Add the entry to the media index.
    await _writer.addToMediaIndex(mediaIndexEntry);

    // Write the data to this media file's cluster.
    await _writer.writeData(PageType.media, mediaRootPageId, file.openRead());
  }

  Future<void> removeMediaFile(int attachmentId) async {
    /*
    Deletes a media file from the rem file and its entry from the media index.
    */

    // Get the media index entry for this attachment.
    final mediaIndexEntry = await _reader.readMediaIndexEntry(attachmentId);

    // if the entry was found, delete it.
    if (mediaIndexEntry.mediaRootPageId != 0) {
      // Remove the media file's content by adding it to the free list.
      await _writer.addToFreeList(mediaIndexEntry.mediaRootPageId);

      // Remove the media file's index entry from the media index table by making its media pointer point nowhere (set mediaRootPageId to 0).
      mediaIndexEntry.mediaRootPageId = 0;
      await _writer.addToMediaIndex(mediaIndexEntry);
    }
  }

  Future<void> readDatabaseToFile(File outputFile) async {
    /*
    Reads the database file within the rem file and writes it to `outputFile`.
    */
    final rootId = _footer.dbRootPageId;
    await _readToFile(rootId, outputFile);
  }

  Future<void> readMediaToFile(int attachmentId, File outputFile) async {
    /*
    Reads the media file related to `attachmentId` stored within the rem file and writes it to `outputFile`.
    */
    final mediaIndexEntry = await _reader.readMediaIndexEntry(attachmentId);
    await _readToFile(mediaIndexEntry.mediaRootPageId, outputFile);
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
