import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';

import 'package:reminiscence/features/data_loader/data_archive_loader/utils.dart';
import 'package:reminiscence/features/data_loader/data_archive_loader/models/chat.dart';

List<Chat> getChats({String? archivePath, Archive? archive}) {
  if (archivePath != null) {
    InputFileStream stream = InputFileStream(archivePath);
    archive = ZipDecoder().decodeStream(stream);
  }

  if (archive == null) {
    return [];
  }

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
