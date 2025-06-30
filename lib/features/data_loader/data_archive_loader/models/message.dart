import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:reminiscence/features/data_loader/data_archive_loader/utils.dart';
import 'package:reminiscence/features/data_loader/data_archive_loader/models/chat.dart';
import 'package:reminiscence/features/data_loader/data_archive_loader/models/message_stack.dart';
import 'package:reminiscence/features/data_loader/data_archive_loader/models/attachment.dart';
import 'package:reminiscence/features/database/tables/attachment_type.dart';
import 'package:reminiscence/features/tokenizer/tokenizer.dart';

class Message {
  final Map<String, dynamic> data;

  final Chat chat;
  final MessageStack messageStack;
  final int index;

  late final String id;
  late final int sentAt;
  late final String senderName;
  late final String content;
  late final List<Attachment> attachments;
  late final Set<String> searchTokens;

  Message({
    required this.data,
    required this.chat,
    required this.messageStack,
    required this.index,
  }) {
    for (var entry in data.entries) {
      if (entry.value is String && entry.value != null) {
        data[entry.key] = decodeData(entry.value);
      }
    }

    sentAt = data["timestamp_ms"] ?? 0;
    senderName = data["sender_name"] ?? "";
    content = data["content"] ?? "";
    id = _generateUniqueId();
    attachments = _getAttachments();
    searchTokens = _getSearchTokens();
  }

  String _generateUniqueId() {
    String inputData = '${chat.id}$sentAt$senderName$content';
    List<int> bytes = utf8.encode(inputData);
    Digest hash = sha256.convert(bytes);
    return hash.toString();
  }

  List<Attachment> _getAttachments() {
    List<Attachment> attachments = [];

    if (data.containsKey("share") && data["share"].containsKey("link")) {
      String link = data["share"]["link"];
      attachments.add(Attachment(type: AttachmentType.link, uri: link));
    }

    Map<String, AttachmentType> attachmentTypes = {
      "photos": AttachmentType.photo,
      "videos": AttachmentType.video,
      "audio_files": AttachmentType.audio,
      "files": AttachmentType.file,
    };

    for (var entry in attachmentTypes.entries) {
      String key = entry.key;
      AttachmentType attachmentType = entry.value;

      for (Map<String, dynamic> item in data[key] ?? []) {
        attachments.add(Attachment(type: attachmentType, uri: item["uri"]));
      }
    }

    return attachments;
  }

  Set<String> _getSearchTokens() {
    final tokens = tokenize(content);
    tokens.addAll(_getReactions());
    return tokens;
  }

  List<String> _getReactions() {
    final List<dynamic> reactionsList = data["reactions"] ?? [];
    return reactionsList.map((r) => decodeData(r["reaction"])).toList();
  }
}
