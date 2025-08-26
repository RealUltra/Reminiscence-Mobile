import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:characters/characters.dart';
import 'package:emoji_regex/emoji_regex.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:reminiscence/features/data_loader/data_archive_loader/models/chat.dart';

String? getDataDir(Archive archive) {
  for (final file in archive) {
    final parts = file.name.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.contains("your_instagram_activity")) {
      final index = parts.indexOf("your_instagram_activity");
      return parts.sublist(0, index).join("/");
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
    if (path.dirname(file.name) == targetDir && !filesAdded.contains(file.name)) {
      archiveFiles.add(file);
      filesAdded.add(file.name);
    }
  }

  return archiveFiles;
}

List<String> listFolders(Archive archive, String targetDir) {
  if (targetDir.isEmpty) {
    targetDir = ".";
  }

  if (targetDir.startsWith("/")) {
    targetDir = targetDir.substring(1);
  }

  if (targetDir.endsWith("/")) {
    targetDir = targetDir.substring(0, targetDir.length - 1);
  }

  List<String> folders = [];

  for (ArchiveFile file in archive) {
    final dirname = path.dirname(file.name);

    if (dirname.startsWith(targetDir)) {
      String relativePath = dirname.substring(targetDir.length);
      final parts = relativePath.split("/").where((x) => x.isNotEmpty).toList();

      if (parts.isNotEmpty && !folders.contains(parts[0])) {
        folders.add(parts[0]);
      }
    }
  }

  return folders;
}

Map<String, ArchiveFile> getArchiveMap(Archive archive, {String? relativeDir}) {
  Map<String, ArchiveFile> result = {};

  for (ArchiveFile file in archive) {
    String filePath = path.normalize(file.name);

    if (relativeDir != null && relativeDir.isNotEmpty) {
      if (filePath.startsWith(relativeDir)) {
        filePath = filePath.substring(relativeDir.length);
        if (filePath.startsWith("/")) {
          filePath = filePath.substring(1);
        }
      } else {
        continue;
      }
    }

    result[filePath] = file;
  }

  return result;
}

bool isValidArchive({String? archivePath, Archive? archive}) {
  assert(archivePath != null || archive != null);

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
