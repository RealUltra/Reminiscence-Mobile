import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:characters/characters.dart';
import 'package:emoji_regex/emoji_regex.dart';
import 'package:path/path.dart' as path;
import 'package:reminiscence/features/data_loader/data_archive_loader/models/chat.dart';

String? getDataDir(Archive archive) {
  for (ArchiveFile file in archive) {
    if (!file.isDirectory) continue;

    List<String> dirs =
        file.name.split('/').where((part) => part.isNotEmpty).toList();

    if (dirs[dirs.length - 1] == "your_instagram_activity") {
      return dirs.sublist(0, dirs.length - 1).join('/');
    }
  }

  return null;
}

String getDmsDir(String dataDir) {
  return "${dataDir.replaceAll(RegExp(r'^/|/$'), '')}/your_instagram_activity/messages/inbox";
}

String decodeData(dynamic data) {
  try {
    if (data is String) {
      String normalizedData = decodeUnicodeEscape(data);
      List<int> byteSequence = latin1.encode(normalizedData);
      String unicodeDecoded = utf8.decode(byteSequence);
      return removeNonPrintableCharacters(unicodeDecoded).trim();
    } else {
      return data.toString();
    }
  } catch (e) {
    if (data is String) {
      return removeNonPrintableCharacters(data).trim();
    } else {
      return data.toString();
    }
  }
}

String decodeUnicodeEscape(String input) {
  String jsonString = '"${input.replaceAll('"', '\\"')}"';
  return jsonDecode(jsonString);
}

String removeNonPrintableCharacters(String inputString) {
  final nonPrintablePattern = RegExp(r'[\u200f\u200e\u200d]+');
  return inputString.replaceAll(nonPrintablePattern, '');
}

List<ArchiveFile> listArchiveDir(Archive archive, String targetDir) {
  if (targetDir.isEmpty) {
    targetDir = ".";
  }

  if (targetDir.startsWith("/")) {
    targetDir = targetDir.substring(1);
  }

  if (targetDir.endsWith("/")) {
    targetDir = targetDir.substring(0, targetDir.length - 1);
  }

  List<String> filesAdded = [];
  List<ArchiveFile> archiveFiles = [];

  for (ArchiveFile file in archive) {
    String fileName = file.name;

    if (path.dirname(fileName) == targetDir && !filesAdded.contains(fileName)) {
      archiveFiles.add(file);
      filesAdded.add(fileName);
    }
  }

  return archiveFiles;
}

Map<String, ArchiveFile> getArchiveMap(Archive archive) {
  Map<String, ArchiveFile> result = {};

  for (ArchiveFile file in archive) {
    result[path.normalize(file.name)] = file;
  }

  return result;
}

bool isValidArchive({String? archivePath, Archive? archive}) {
  if (archivePath == null && archive == null) return false;

  if (archivePath != null) {
    InputFileStream stream = InputFileStream(archivePath);
    archive = ZipDecoder().decodeStream(stream);
  }

  return getDataDir(archive!) != null;
}

String? findUserName(List<Chat> chats) {
  Map<String, int> usersCount = {};

  for (Chat chat in chats) {
    for (String participant in chat.participants) {
      if (!usersCount.containsKey(participant)) {
        usersCount[participant] = 0;
      }
      usersCount[participant] = usersCount[participant]! + 1;
    }
  }

  if (usersCount.isEmpty) {
    return null;
  }

  String userName = usersCount.keys.first;
  int userCount = usersCount.values.first;

  for (var entry in usersCount.entries) {
    if (entry.value > userCount) {
      userName = entry.key;
      userCount = entry.value;
    }
  }

  return userName;
}

String removeEmojis(String input) {
  return input.characters.where((char) => !emojiRegex().hasMatch(char)).join();
}
