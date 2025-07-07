import 'dart:typed_data';

import 'package:reminiscence/features/reminiscence_file_io/components/media_index_entry.dart';
import 'package:reminiscence/features/reminiscence_file_io/utils.dart';

class MediaIndexTable {
  List<MediaIndexEntry> entries;

  MediaIndexTable(this.entries);

  factory MediaIndexTable.fromBytes(Uint8List bytes) {
    final entries = <MediaIndexEntry>[];

    for (
      int offset = 0;
      (offset + mediaIndexEntrySize) <= bytes.length;
      offset += 8
    ) {
      final entryBytes = Uint8List.sublistView(
        bytes,
        offset,
        offset + mediaIndexEntrySize,
      );
      final entry = MediaIndexEntry.fromBytes(entryBytes);

      if (entry.mediaRootPageId != 0) {
        entries.add(entry);
      }
    }

    return MediaIndexTable(entries);
  }
}
