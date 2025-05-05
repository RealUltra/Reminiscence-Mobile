import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';

import 'package:reminiscence/features/data_loader/data_archive_loader/utils.dart';
import 'package:reminiscence/features/data_loader/data_archive_loader/models/chat.dart';
import 'package:reminiscence/features/data_loader/data_archive_loader/models/message.dart';

class MessageStack {
  ArchiveFile archiveFile;
  final Chat chat;

  final int stackNum;

  MessageStack({
    required this.archiveFile,
    required this.chat,
    required this.stackNum
  });

  static MessageStack load(Chat chat, ArchiveFile archiveFile) {
    String fileName = path.basename(archiveFile.name);
    RegExp regex = RegExp(r"message_(\d+).json");
    int stackNum = int.parse(regex.firstMatch(fileName)!.group(1)!);
    return MessageStack(chat: chat, stackNum: stackNum, archiveFile: archiveFile);
  }

  Iterable<Message> messages() sync* {
    Map<String, dynamic> jsonData = _getJsonData();

    List<dynamic> messages = jsonData['messages'];

    for (int i = 0; i < messages.length; i++) {
      Map<String, dynamic> messageData = messages[i];
      Message message = Message(data: messageData, chat: chat, messageStack: this, index: i);
      yield message;
    }

  }

  Map<String, dynamic> getMetaData() {
    Map<String, dynamic> metaData = {
      'chatTitle': "",
      'participants': <String>[]
    };

    Map<String, dynamic> jsonData = _getJsonData();

    // Load Participants
    for (var participant in (jsonData['participants'] ?? [])) {
      metaData['participants'].add(decodeData(participant['name']));
    }

    // Load chatTitle
    String? title = jsonData['title'];
    metaData['chatTitle'] = (title != null) ? decodeData(title) : "";

    return metaData;
  }

  Map<String, dynamic> _getJsonData() {
    InputStream stream = archiveFile.getContent()!;
    String jsonString = utf8.decode(stream.readBytes(stream.length).toUint8List());
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    return jsonData;
  }

}