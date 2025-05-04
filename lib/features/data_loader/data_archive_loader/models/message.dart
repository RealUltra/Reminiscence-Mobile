import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../utils.dart';
import 'chat.dart';
import 'message_stack.dart';

class Message {
  final Map<String, dynamic> data;

  final Chat chat;
  final MessageStack messageStack;
  final int index;

  late final String id;
  late final String senderName;
  late final DateTime sentAt;
  late final String content;

  Message({
    required this.data,
    required this.chat,
    required this.messageStack,
    required this.index
  }) {
    
    for (var entry in data.entries) {
      if (entry.value is String && entry.value != null) {
        data[entry.key] = decodeData(entry.value);
      }
    }

    senderName = data["sender_name"] ?? "";
    sentAt = DateTime.fromMillisecondsSinceEpoch(data["timestamp_ms"] ?? 0);
    content = data["content"] ?? "";
    id = _generateUniqueId();

  }

  String _generateUniqueId() {
    String inputData = '${chat.id}${sentAt.millisecondsSinceEpoch}$senderName$content';
    List<int> bytes = utf8.encode(inputData);
    Digest hash = sha256.convert(bytes);
    return hash.toString();
  }

}