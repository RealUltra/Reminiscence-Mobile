import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:reminiscence/features/data_loader/data_archive_loader/data_archive_loader.dart';
import 'package:reminiscence/features/data_loader/data_archive_loader/message_reader.dart';
import 'package:reminiscence/features/data_loader/data_archive_loader/utils.dart';
import 'package:reminiscence/features/database/database.dart';

import 'package:reminiscence/features/data_loader/data_archive_loader/models/chat.dart'
    as archive_loader;
import 'package:reminiscence/features/database/tables/attachment_type.dart';
import 'package:reminiscence/features/encryption/encryption.dart';
import 'package:reminiscence/features/encryption/kdf.dart';
import 'package:reminiscence/features/reminiscence_file_io/reminiscence_file.dart';
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
  required List<String> archivePaths,
  String? password,
  RootIsolateToken? rootToken,
  SendPort? sendPort,
  double progressStart = 0.0,
  double progressValue = 1.0,
}) async {
  assert(archivePaths.isNotEmpty);

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

  // Derive the encryption key.
  final derivedKey =
      password != null ? await deriveKey(password: password) : null;

  // Initialize the .rem file encoder.
  String fileName = path.basenameWithoutExtension(archivePaths[0]);
  String outputPath = path.join(tempDir.path, "$fileName.rem");

  final nonce = Uint8List.fromList(derivedKey?.nonce ?? []);

  Uint8List? encryptedNonce;

  if (derivedKey != null) {
    encryptedNonce = Uint8List.fromList(
      await encrypt(derivedKey.nonce, derivedKey.secretKey),
    );
  }

  final remFile = ReminiscenceFile();

  await remFile.create(
    outputPath,
    isEncrypted: password != null,
    nonce: nonce,
    encryptedNonce: encryptedNonce,
  );

  // Create an empty database to start loading these chats into.
  final dbPath = '${tempDir.path}/database.db';
  final db = await createFreshDatabase(dbPath, password, rootToken);

  if (isCancelled) return null;

  final stopwatch = Stopwatch()..start();

  final archiveMap = <String, ArchiveFile>{};

  for (int i = 0; i < archivePaths.length; i++) {
    final archivePath = archivePaths[i];

    await insertChatsFromArchive(
      archivePath: archivePath,
      db: db,
      progressStart:
          (progressStart + (i / archivePaths.length * 0.49)) * progressValue,
      progressValue: 0.49 / archivePaths.length * progressValue,
      archiveMap: archiveMap,
      isCancelled: () => isCancelled,
      sendPort: sendPort,
    );
  }

  if (isCancelled) return null;

  stopwatch.stop();
  debugPrint(
    "Time taken to add all the chats to the database: ${stopwatch.elapsed.inSeconds} seconds",
  );

  stopwatch
    ..reset()
    ..start();
  // Insert the media for all the attachments into the rem file
  await insertMediaFiles(
    db,
    archiveMap,
    remFile,
    derivedKey,
    () => isCancelled,
    (attachmentsDone, totalAttachments) async {
      sendPort?.send({
        "type": "progress",
        "progress": {
          "value":
              progressStart +
              (0.49 + attachmentsDone / totalAttachments * 0.5) * progressValue,
          "label":
              'Loading Chat Media...\n($attachmentsDone / $totalAttachments)',
        },
      });
    },
  );

  if (isCancelled) return null;

  debugPrint(
    "`insertMediaFiles` Duration: ${stopwatch.elapsed.inSeconds} seconds",
  );

  sendPort?.send({
    "type": "progress",
    "progress":
        Progress(
          value: progressStart + 0.99 * progressValue,
          label: "Bundling everything up...",
        ).toMap(),
  });

  // Close the database
  await db.close();

  // Adding the database to the rem file.
  await remFile.writeDatabase(File(dbPath));

  // Close the rem file
  await remFile.close();

  sendPort?.send({
    "type": "progress",
    "progress": Progress(value: progressStart + progressValue).toMap(),
  });

  return outputPath;
}

Future<void> insertChatsFromArchive({
  required String archivePath,
  required AppDatabase db,
  required double progressStart,
  required double progressValue,
  required Map<String, ArchiveFile> archiveMap,
  required bool Function() isCancelled,
  required SendPort? sendPort,
}) async {
  // Open the archive.
  InputFileStream stream = InputFileStream(archivePath);
  final archive = ZipDecoder().decodeStream(stream);

  // Extract the chats from the archive.
  final chats = getChats(archive: archive);

  if (isCancelled()) return;

  // Insert all the chats from the archive into the database
  double stacksDone = 0;
  int totalStacks = chats
      .map((c) => c.messageStacks.length)
      .fold(0, (sum, length) => sum + length);

  archiveMap.addAll(getArchiveMap(archive, relativeDir: getDataDir(archive)));

  final messageReader = MessageReader(chats);

  for (int i = 0; i < chats.length; i++) {
    final chat = chats[i];

    await insertArchiveChat(db, chat, messageReader, (int increment) async {
      sendPort?.send({
        "type": "progress",
        "progress": {
          "value":
              progressStart +
              ((stacksDone + increment) / totalStacks) * progressValue,
          "label":
              'Loading Chat Messages:\n${chat.title}\n(${i + 1} / ${chats.length})',
        },
      });
    });

    stacksDone += chat.messageStacks.length;

    if (isCancelled()) return;
  }
}

Future<void> insertArchiveChat(
  AppDatabase db,
  archive_loader.Chat archiveChat,
  MessageReader messageReader,
  Future<void> Function(int) updateProgress,
) async {
  // Create database chat
  ChatsCompanion chat = ChatsCompanion(
    id: Value(archiveChat.id),
    title: Value(archiveChat.title),
    userName: Value(messageReader.userName),
  );

  // Preparing participant objects to add to the database later
  final participantsToInsert =
      archiveChat.participants
          .map(
            (name) => ParticipantsCompanion(chatId: chat.id, name: Value(name)),
          )
          .toList();

  await db.batch((batch) {
    batch.insert(db.chats, chat, mode: InsertMode.insertOrIgnore);
    batch.insertAll(db.participants, participantsToInsert);
  });

  // Add messages to database
  int stacksDone = 0;

  messageReader.initialize(archiveChat);

  for (final messageStack in archiveChat.messageStacks) {
    updateProgress(stacksDone);

    // Efficiently inserting all the messages and attachments into the database.
    await db.batch((batch) {
      for (final archiveMessage in messageReader.messages(messageStack)) {
        final message = MessagesCompanion(
          id: Value(archiveMessage.id),
          chatId: chat.id,
          rawData: Value(jsonEncode(archiveMessage.data)),
          sentAt: Value(archiveMessage.sentAt),
          senderName: Value(archiveMessage.senderName),
          content: Value(archiveMessage.content),
          noEmojisContent: Value(
            removeEmojis(archiveMessage.content.toLowerCase()),
          ),
          searchContent: Value(archiveMessage.searchContent),
        );

        batch.insert(db.messages, message, mode: InsertMode.insertOrIgnore);

        // Add attachments to database
        for (final archiveAttachment in archiveMessage.attachments) {
          final attachment = AttachmentsCompanion(
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
  Map<String, ArchiveFile> archiveMap,
  ReminiscenceFile remFile,
  DerivedKey? derivedKey,
  bool Function() isCancelled,
  Future<void> Function(int, int) updateProgress,
) async {
  final results =
      await db
          .customSelect(
            """
              SELECT 
                id, 
                uri 
              
              FROM 
                attachments
                
              WHERE 
                type <> ?

              ORDER BY
                id
            """,
            variables: [Variable.withString(AttachmentType.link.name)],
          )
          .get();

  int attachmentsDone = 0;

  for (final row in results) {
    final attachmentId = row.read<int>('id');
    final uri = row.read<String>('uri');

    final archiveFile = archiveMap[path.normalize(uri)];

    updateProgress(attachmentsDone, results.length);

    if (archiveFile != null) {
      InputStream inputStream = archiveFile.rawContent!.getStream();

      if (derivedKey != null) {
        final encryptedStream = encryptStream(
          inputStream: inputStream,
          secretKey: derivedKey.secretKey,
        );

        await remFile.addMediaFile(attachmentId, stream: encryptedStream);
      } else {
        await remFile.addMediaFile(attachmentId, inputStream: inputStream);
      }
    }

    attachmentsDone++;

    if (isCancelled()) return;
  }
}
