import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:reminiscence/features/database/models/chat.dart';
import 'package:reminiscence/features/database/models/participant.dart';
import 'package:reminiscence/features/database/models/message.dart';
import 'package:reminiscence/features/database/models/attachment.dart';

import 'package:reminiscence/features/database/daos/chat_dao.dart';
import 'package:reminiscence/features/database/daos/participant_dao.dart';
import 'package:reminiscence/features/database/daos/message_dao.dart';
import 'package:reminiscence/features/database/daos/attachment_dao.dart';

part 'database.g.dart';

// flutter pub run build_runner build --delete-conflicting-outputs

@Database(version: 1, entities: [Chat, Participant, Message, Attachment])
abstract class AppDatabase extends FloorDatabase {
  ChatDao get chatDao;
  ParticipantDao get participantDao;
  MessageDao get messageDao;
  AttachmentDao get attachmentDao;
}