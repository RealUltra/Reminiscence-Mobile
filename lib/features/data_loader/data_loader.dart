import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';

import 'data_archive_loader/utils.dart';
import 'data_archive_loader/models/chat.dart';

List<Chat> getChats(String archivePath) {
  InputFileStream stream = InputFileStream(archivePath);
  Archive archive = ZipDecoder().decodeStream(stream);

  String? dataDir = getDataDir(archive);

  if (dataDir == null) {
    return [];
  }

  List<Chat> chats = [];

  for (ArchiveFile archiveFile in listArchiveDir(archive, getDmsDir(dataDir))) {
    String folderName = path.basename(archiveFile.name);
    Chat chat = Chat.load(folderName, archive, dataDir);
    chat.loadMessageStacks();
    chats.add(chat);
  }

  return chats;
}