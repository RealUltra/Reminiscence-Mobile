import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_loader/data_archive_loader/models/chat.dart';
import 'package:reminiscence/features/data_loader/data_archive_loader/models/message.dart';
import 'package:reminiscence/features/data_loader/data_archive_loader/models/message_stack.dart';
import 'package:reminiscence/features/data_loader/data_archive_loader/utils.dart';

class MessageReader {
  final List<Chat> chats;

  // To remove auto-detected system messages
  final Map<int, List<String>> reactors = {};
  final Map<int, List<String>> reactions = {};
  final Set<String> systemMessages = {};

  late final String? userName;

  MessageReader(this.chats) {
    userName = findUserName(chats);
  }

  void initialize(Chat chat) {
    reactors.clear();
    reactions.clear();

    for (final messageStack in chat.messageStacks.reversed) {
      for (final message in messageStack.messagesReverse()) {
        int timestampSeconds = (message.sentAt / 1000).floor();
        String noEmojisContent = removeEmojis(message.content);

        if (reactors.containsKey(timestampSeconds)) {
          if (reactors[timestampSeconds]!.contains(message.senderName)) {
            int reactionIndex = reactors[timestampSeconds]!.indexOf(
              message.senderName,
            );

            if (message.content.characters.contains(
              reactions[timestampSeconds]![reactionIndex],
            )) {
              if (!systemMessages.contains(noEmojisContent)) {
                systemMessages.add(noEmojisContent);
              }
            }
          }
        }

        for (Map<String, dynamic> reaction in message.data["reactions"] ?? []) {
          if (reaction.containsKey("timestamp") &&
              reaction.containsKey("actor") &&
              reaction.containsKey("reaction")) {
            int timestamp = reaction["timestamp"];
            String reactorName = reaction["actor"];
            String reactionStr = reaction["reaction"];

            reactors[timestamp] ??= [];
            reactions[timestamp] ??= [];

            if (!reactors[timestamp]!.contains(reactorName)) {
              reactors[timestamp]!.add(reactorName);
              reactions[timestamp]!.add(decodeData(reactionStr));
            }
          }
        }
      }
    }
  }

  Iterable<Message> messages(MessageStack messageStack) sync* {
    // To avoid double messages.
    Set<String> usedMessageIds = {};

    for (final message in messageStack.messages()) {
      if (usedMessageIds.contains(message.id)) continue;

      if (!isSystemMessage(message)) {
        yield message;
      }

      usedMessageIds.add(message.id);
    }
  }

  bool isSystemMessage(Message message) {
    int timestampSeconds = (message.sentAt / 1000).floor();
    String noEmojisContent = removeEmojis(message.content);

    if (message.data.containsKey("call_duration")) {
      return true;
    }

    if (message.data["is_unsent"] == true) {
      return true;
    }

    if (systemMessages.contains(noEmojisContent)) {
      return true;
    }

    if (reactors.containsKey(timestampSeconds)) {
      if (reactors[timestampSeconds]!.contains(message.senderName)) {
        int reactionIndex = reactors[timestampSeconds]!.indexOf(
          message.senderName,
        );

        if (message.content.characters.contains(
          reactions[timestampSeconds]![reactionIndex],
        )) {
          return true;
        }
      }
    }

    return false;
  }
}
