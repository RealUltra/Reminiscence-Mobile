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

  final dataDir = getDataDir(archive);

  if (dataDir == null) {
    return [];
  }

  final chats = <Chat>[];

  for (final folderName in listFolders(archive, getDmsDir(dataDir))) {
    final chat = Chat.load(folderName, archive, dataDir);
    chat.loadMessageStacks();
    chats.add(chat);
  }

  return chats;
}
