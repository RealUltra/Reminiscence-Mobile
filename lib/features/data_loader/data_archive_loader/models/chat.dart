import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';

import '../utils.dart';
import 'message_stack.dart';

class Chat {
  final Archive archive;
  final String dataDir;

  final String folderName;

  String title = "";
  List<String> participants = [];

  final List<dynamic> messageStacks = [];

  Chat({
    required this.archive,
    required this.dataDir,
    required this.folderName
  });

  static Chat load(String folderName, Archive archive, String dataDir) {
    return Chat(archive: archive, dataDir: dataDir, folderName: folderName);
  }

  void loadMessageStacks() {
    messageStacks.clear();

    RegExp regex = RegExp(r'message_\d+.json');
    String folderPath = "$dmsDir/$folderName";

    for (ArchiveFile archiveFile in listArchiveDir(archive, folderPath)) {
      if (regex.hasMatch(path.basename(archiveFile.name))) {
        MessageStack messageStack = MessageStack.load(this, archiveFile);
        messageStacks.add(messageStack);

        Map<String, dynamic> metaData = messageStack.getMetaData();
        title = metaData['chatTitle'];
        participants = metaData['participants'];
      }
    }

    messageStacks.sort((a, b) => a.stackNum.compareTo(b.stackNum));
  }

  int get id {
    if (!folderName.contains("_")) {
      return int.tryParse(folderName) ?? -1;

    } else {
      List<String> parts = folderName.split('_');
      return int.parse(parts[parts.length - 1]);
    }
  }

  String get dmsDir => getDmsDir(dataDir);
  String get otherContentDir => getOtherContentDir(dataDir);
}