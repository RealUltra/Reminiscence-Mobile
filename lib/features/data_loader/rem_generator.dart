import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:reminiscence/features/data_loader/data_archive_loader/data_archive_loader.dart';
import 'package:reminiscence/features/database/database.dart';

import 'package:reminiscence/features/data_loader/data_archive_loader/models/chat.dart' as archive_loader;
import 'package:reminiscence/features/data_loader/data_archive_loader/models/message_stack.dart' as archive_loader;
import 'package:reminiscence/features/data_loader/data_archive_loader/models/message.dart' as archive_loader;
import 'package:reminiscence/features/data_loader/data_archive_loader/models/attachment.dart' as archive_loader;
import 'package:reminiscence/features/database/models/attachment_type.dart';

Future<AppDatabase> createFreshDatabase() async {
  // Determine the path of the file based on AppDatabase._openConnection() in database.dart.
  final databasesDir = await getApplicationSupportDirectory();
  final databasePath = path.join(databasesDir.path, "user_data.sqlite");
  final databaseFile = File(databasePath);

  if (await databaseFile.exists()) {
    await databaseFile.delete();
  }
  
  return AppDatabase();
}

Future<void> createFreshFolder(String folderPath) async {
  final folder = Directory(folderPath);

  if (await folder.exists()) {
    await folder.delete(recursive: true);
  }

  await folder.create(recursive: true);
}

Future<String> createRemFile(String archivePath) async {
  final tempDir = await getTemporaryDirectory();

  final List<archive_loader.Chat> chats = getChats(archivePath);

  final dbPath = '${tempDir.path}/database.db';
  final db = await createFreshDatabase();

  for (var chat in chats) {
    debugPrint(chat.title);
    await insertArchiveChat(db, chat);
  }

  // Save the database to the correct path.
  File dbFile = File(dbPath);

  if (await dbFile.exists()) {
    await dbFile.delete();
  }

  await db.customStatement('VACUUM INTO ?', [dbFile.path]);
  //

  // Creating media folder
  final baseDir = await getTemporaryDirectory(); // or getApplicationDocumentsDirectory()
  final mediaDir = '${baseDir.path}/media';

  await createFreshFolder(mediaDir);

  if (chats.isNotEmpty) {
    Archive archive = chats[0].archive;
    
    // Get all the attachments that are not links i.e files, videos, photos, audios
    final attachments = await (db.select(db.attachments)
    ..where((a) => a.type.isNotExp(Variable.withString(AttachmentType.link.name)))
    ..addColumns([db.attachments.id, db.attachments.uri])
    ).get();

    // Create a hash map for quick look up - path to id.
    final Map<String, int> mediaFilesAndIds = {
      for (Attachment attachment in attachments)
        path.normalize(attachment.uri): attachment.id
    };

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

  String fileName = path.basenameWithoutExtension(archivePath);
  String outputPath = path.join(tempDir.path, "$fileName.rem");

  encoder.create(outputPath);

  await encoder.addDirectory(Directory(mediaDir), includeDirName: true);
  await encoder.addFile(File(dbPath));

  // Close the zip file
  await encoder.close();

  // Close the database
  await db.close();

  return outputPath;
}

Future<void> insertArchiveChat(AppDatabase db, archive_loader.Chat archiveChat) async {
  // Create database chat
  ChatsCompanion chat = ChatsCompanion(id: Value(archiveChat.id), title: Value(archiveChat.title));

  // Add chat to database
  db.into(db.chats).insert(chat);

  // Preparing participant objects to add to the database later
  final participantsToInsert = archiveChat.participants.map(
    (name) => ParticipantsCompanion(chatId: chat.id, name: Value(name))
  ).toList();

  // Add messages to database
  for (archive_loader.MessageStack messageStack in archiveChat.messageStacks) {
    List<MessagesCompanion> messagesToInsert = [];
    List<AttachmentsCompanion> attachmentsToInsert = []; 
    List<String> usedMessageIds = [];

    for (archive_loader.Message archiveMessage in messageStack.messages()) {
      if (usedMessageIds.contains(archiveMessage.id)) {
        continue;
      }

      MessagesCompanion message = MessagesCompanion(
        id: Value(archiveMessage.id), 
        chatId: chat.id, 
        rawData: Value(jsonEncode(archiveMessage.data)),
        sentAt: Value(archiveMessage.sentAt), 
        senderName: Value(archiveMessage.senderName), 
        content: Value(archiveMessage.content)
      );

      messagesToInsert.add(message);
      usedMessageIds.add(message.id.value);

      // Add attachments to database
      for (archive_loader.Attachment archiveAttachment in archiveMessage.attachments) {
        AttachmentsCompanion attachment = AttachmentsCompanion(messageId: message.id, type: Value(archiveAttachment.type), uri: Value(archiveAttachment.uri));
        attachmentsToInsert.add(attachment);
      }
    }

    // Efficiently inserting all the participants, messages and attachments into the database.
    await db.batch((batch) {
      batch.insertAll(db.participants, participantsToInsert);
      batch.insertAll(db.messages, messagesToInsert);
      batch.insertAll(db.attachments, attachmentsToInsert);
    });

  }
}