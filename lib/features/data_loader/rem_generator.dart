import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:reminiscence/features/data_loader/data_archive_loader/data_archive_loader.dart';
import 'package:reminiscence/features/data_loader/data_archive_loader/utils.dart';
import 'package:reminiscence/features/database/database.dart';

import 'package:reminiscence/features/data_loader/data_archive_loader/models/chat.dart'
    as archive_loader;
import 'package:reminiscence/features/data_loader/data_archive_loader/models/message_stack.dart'
    as archive_loader;
import 'package:reminiscence/features/data_loader/data_archive_loader/models/message.dart'
    as archive_loader;
import 'package:reminiscence/features/data_loader/data_archive_loader/models/attachment.dart'
    as archive_loader;
import 'package:reminiscence/features/database/models/attachment_type.dart';
import 'package:reminiscence/features/encryption/encryption.dart';
import 'package:reminiscence/features/encryption/kdf.dart';
import 'package:reminiscence/ui/pages/loading_screen/progress.dart';

Future<AppDatabase> createFreshDatabase(
  String dbPath,
  String? password,
  RootIsolateToken? rootToken,
) async {
  // Determine the path of the file based on AppDatabase._openConnection() in database.dart.
  final databaseFile = File(dbPath);

  if (await databaseFile.exists()) {
    await databaseFile.delete();
  }

  return AppDatabase(dbPath: dbPath, password: password, token: rootToken);
}

Future<void> createFreshFolder(String folderPath) async {
  final folder = Directory(folderPath);

  if (await folder.exists()) {
    await folder.delete(recursive: true);
  }

  await folder.create(recursive: true);
}

Future<String?> createRemFile({
  required String archivePath,
  String? password,
  RootIsolateToken? rootToken,
  SendPort? sendPort,
}) async {
  // Set up receive port and cancellation token
  ReceivePort? receivePort = sendPort != null ? ReceivePort() : null;
  bool isCancelled = false;

  if (receivePort != null) {
    sendPort!.send({"type": "sendPort", "sendPort": receivePort.sendPort});
  }

  receivePort?.listen((message) {
    if (message is! Map<String, dynamic>) return;

    if (message["type"] == "cancel") {
      isCancelled = true;
    }
  });

  final tempDir = await getTemporaryDirectory();
  //

  // Initialize the .rem file encoder.
  String fileName = path.basenameWithoutExtension(archivePath);
  String outputPath = path.join(tempDir.path, "$fileName.rem");

  final encoder = ZipFileEncoder();
  encoder.create(outputPath);

  // Open the archive.
  InputFileStream stream = InputFileStream(archivePath);
  final archive = ZipDecoder().decodeStream(stream);

  // Extract the chats from the archive.
  final chats = await getChats(archive: archive);

  if (isCancelled) return null;

  // Create an empty database to start loading these chats into.
  final dbPath = '${tempDir.path}/database.db';
  final db = await createFreshDatabase(dbPath, password, rootToken);

  if (isCancelled) return null;

  // Insert all the chats from the archive into the database
  double stacksDone = 0;
  int totalStacks = chats
      .map((c) => c.messageStacks.length)
      .fold(0, (sum, length) => sum + length);

  final Map<String, ArchiveFile> archiveMap = getArchiveMap(archive);

  for (var chat in chats) {
    debugPrint("Chat Title: ${chat.title}");

    final stacksMid = chat.messageStacks.length / 2;

    await insertArchiveChat(db, chat, (int increment) async {
      sendPort?.send({
        "type": "progress",
        "progress": {
          "value": (stacksDone + increment * 0.5) / totalStacks * 0.99,
          "label": 'Loading Chat Messages:\n${chat.title}',
        },
      });
    });

    stacksDone += stacksMid;

    await insertMediaFiles(db, chat.id, archiveMap, encoder, (
      double progress,
    ) async {
      sendPort?.send({
        "type": "progress",
        "progress": {
          "value": (stacksDone + progress * stacksMid) / totalStacks * 0.99,
          "label": 'Loading Chat Media:\n${chat.title}',
        },
      });
    });

    stacksDone += stacksMid;

    if (isCancelled) return null;
  }
  //

  // Deriving the encryption key from the password.
  final derivedKey =
      password != null ? (await deriveKey(password: password)) : null;

  sendPort?.send({
    "type": "progress",
    "progress":
        Progress(value: 0.99, label: "Bundling everything up...").toMap(),
  });

  // Adding the database and nonce to the rem file.
  await encoder.addFile(File(dbPath), "database.db");
  encoder.addArchiveFile(
    ArchiveFile.bytes("nonce.txt", derivedKey?.nonce ?? []),
  );

  // Close the rem file
  await encoder.close();

  // Close the database
  await db.close();

  sendPort?.send({
    "type": "progress",
    "progress": Progress(value: 1.0).toMap(),
  });

  return outputPath;
}

Future<void> insertArchiveChat(
  AppDatabase db,
  archive_loader.Chat archiveChat,
  Future<void> Function(int) updateProgress,
) async {
  // Create database chat
  ChatsCompanion chat = ChatsCompanion(
    id: Value(archiveChat.id),
    title: Value(archiveChat.title),
  );

  // Preparing participant objects to add to the database later
  final participantsToInsert =
      archiveChat.participants
          .map(
            (name) => ParticipantsCompanion(chatId: chat.id, name: Value(name)),
          )
          .toList();

  await db.batch((batch) {
    batch.insert(db.chats, chat);
    batch.insertAll(db.participants, participantsToInsert);
  });

  // Add messages to database
  int stacksDone = 0;

  for (archive_loader.MessageStack messageStack in archiveChat.messageStacks) {
    Set<String> usedMessageIds = {};

    updateProgress(stacksDone);

    // Efficiently inserting all the messages and attachments into the database.
    await db.batch((batch) {
      for (archive_loader.Message archiveMessage in messageStack.messages()) {
        if (usedMessageIds.contains(archiveMessage.id)) continue;

        MessagesCompanion message = MessagesCompanion(
          id: Value(archiveMessage.id),
          chatId: chat.id,
          rawData: Value(jsonEncode(archiveMessage.data)),
          sentAt: Value(archiveMessage.sentAt),
          senderName: Value(archiveMessage.senderName),
          content: Value(archiveMessage.content),
        );

        batch.insert(db.messages, message);
        usedMessageIds.add(message.id.value);

        // Add attachments to database
        for (archive_loader.Attachment archiveAttachment
            in archiveMessage.attachments) {
          AttachmentsCompanion attachment = AttachmentsCompanion(
            messageId: message.id,
            type: Value(archiveAttachment.type),
            uri: Value(archiveAttachment.uri),
          );

          batch.insert(db.attachments, attachment);
        }
      }
    });

    stacksDone++;
  }

  updateProgress(stacksDone);
}

Future<void> insertMediaFiles(
  AppDatabase db,
  int chatId,
  Map<String, ArchiveFile> archiveMap,
  ZipFileEncoder remEncoder,
  Future<void> Function(double) updateProgress,
) async {
  final results =
      await db
          .customSelect(
            'SELECT a.id, a.uri FROM attachments a JOIN messages m ON a.message_id = m.id WHERE m.chat_id = ? AND a.type <> ?',
            variables: [
              Variable.withInt(chatId),
              Variable.withString(AttachmentType.link.name),
            ],
          )
          .get();

  final List<Map<String, dynamic>> attachments = results
      .map((row) => {'id': row.read<int>('id'), 'uri': row.read<String>('uri')})
      .toList(growable: false);

  int attachmentsDone = 0;

  for (Map<String, dynamic> attachment in attachments) {
    final attachmentId = attachment["id"];
    final uri = attachment["uri"];

    final archiveFile = archiveMap[path.normalize(uri)];
    final targetPath = path.join("media", "$attachmentId");

    updateProgress(attachmentsDone / attachments.length);

    if (archiveFile != null) {
      remEncoder.addArchiveFile(
        ArchiveFile.stream(
          targetPath,
          archiveFile.getContent() ?? InputMemoryStream.empty(),
        ),
      );
    }

    attachmentsDone++;
  }
}
