import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

import 'package:reminiscence/features/data_loader/data_archive_loader/data_archive_loader.dart';
import 'package:reminiscence/features/database/database.dart';

import 'package:reminiscence/features/data_loader/data_archive_loader/models/chat.dart' as archive_loader;
import 'package:reminiscence/features/data_loader/data_archive_loader/models/message_stack.dart' as archive_loader;
import 'package:reminiscence/features/data_loader/data_archive_loader/models/message.dart' as archive_loader;
import 'package:reminiscence/features/data_loader/data_archive_loader/models/attachment.dart' as archive_loader;
import 'package:reminiscence/features/database/models/attachment_type.dart';

import 'package:reminiscence/features/database/models/chat.dart';
import 'package:reminiscence/features/database/models/participant.dart';
import 'package:reminiscence/features/database/models/message.dart';
import 'package:reminiscence/features/database/models/attachment.dart';


Future<AppDatabase> createFreshDatabase(String dbPath) async {
  final dbFile = File(dbPath);

  if (await dbFile.exists()) {
    await dbFile.delete();
  }

  final db = await $FloorAppDatabase.databaseBuilder(dbPath).build();

  return db;
}

Future<String> createFreshMediaFolder() async {
  final baseDir = await getTemporaryDirectory(); // or getApplicationDocumentsDirectory()
  final folderPath = '${baseDir.path}/media';

  final folder = Directory(folderPath);
  if (await folder.exists()) {
    await folder.delete(recursive: true);
  }

  await folder.create(recursive: true);

  return folder.path;
}

Future<String> createRemFile(String archivePath) async {
  final tempDir = await getTemporaryDirectory();

  final List<archive_loader.Chat> chats = getChats(archivePath);

  final dbPath = '${tempDir.path}/temp_database.db';
  final db = await createFreshDatabase(dbPath);

  // Map the media file paths to their equivalent attachment ids.
  Map<String, int> mediaFilesAndIds = {};

  for (var chat in chats) {
    debugPrint(chat.title);
    await insertArchiveChat(db, chat, mediaFilesAndIds);
  }

  await db.close();

  // Creating media folder
  String mediaDir = await createFreshMediaFolder();

  if (chats.isNotEmpty) {
    Archive archive = chats[0].archive;

    for (ArchiveFile file in archive) {
      if (!file.isFile) continue;

      String filePath = path.normalize(file.name);
      int? attachmentId = mediaFilesAndIds[filePath];

      if (attachmentId != null) {
        String mediaPath = path.join(mediaDir, "$attachmentId");
        final mediaFile = File(mediaPath);
        await mediaFile.writeAsBytes(file.content as List<int>);
      }
    }
  }
  //

  // Creating .rem file.
  final encoder = ZipFileEncoder();

  String outputPath = path.join(tempDir.path, "output.rem");

  encoder.create(outputPath);

  encoder.addDirectory(Directory(mediaDir), includeDirName: true);
  encoder.addFile(File(dbPath));

  encoder.close();

  return outputPath;
}

Future<void> insertArchiveChat(AppDatabase db, archive_loader.Chat archiveChat, Map<String, int> mediaFilesAndIds) async {
  // Create database chat
  Chat chat = Chat(id: archiveChat.id, title: archiveChat.title);

  // Add chat to database
  await db.chatDao.insertItem(chat);

  // Add participants to database
  List<Participant> participants = archiveChat.participants.map(
    (name) => Participant(chatId: chat.id, name: name)
  ).toList();
  await db.participantDao.insertItems(participants);

  // Add messages to database
  for (archive_loader.MessageStack messageStack in archiveChat.messageStacks) {
    List<Message> messages = [];
    List<Attachment> attachments = []; 
    List<String> attachmentUris = [];

    for (archive_loader.Message archiveMessage in messageStack.messages()) {
      Message message = Message(
        id: archiveMessage.id, 
        chatId: chat.id, 
        rawData: jsonEncode(archiveMessage.data),
        sentAt: archiveMessage.sentAt, 
        senderName: archiveMessage.senderName, 
        content: archiveMessage.content
      );

      messages.add(message);

      // Add attachments to database
      for (archive_loader.Attachment archiveAttachment in archiveMessage.attachments) {
        Attachment attachment;

        if (archiveAttachment.type == AttachmentType.link) {
          attachment = Attachment(messageId: message.id, type: archiveAttachment.type.name, link: archiveAttachment.uri);
          attachmentUris.add("");
        } else {
          attachment = Attachment(messageId: message.id, type: archiveAttachment.type.name);
          attachmentUris.add(archiveAttachment.uri);
        }

        attachments.add(attachment);
      }
    }

    await db.messageDao.insertItems(messages);
    List<int> attachmentIds = await db.attachmentDao.insertItems(attachments);

    for (int i = 0; i < attachmentUris.length; i++) {
      String uri = attachmentUris[i];

      if (uri.isNotEmpty) {
        String fullPath = path.join(archiveChat.dataDir, uri);
        mediaFilesAndIds[fullPath] = attachmentIds[i];
      }
    }
  }

}