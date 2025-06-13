import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';

class MessageReader {
  final ReminiscenceData data;
  final ChatDto chat;

  final batchSize = 1000;
  Map<int, MessageDto> messages = {};
  List<int> messageIndexes = [];

  MessageReader({required this.data, required this.chat});

  Future<MessageDto?> messageAt(int index) async {
    // Invalid index
    if (index < 0 || index >= chat.messageCount) {
      return null;
    }

    // Index not in currently loaded data
    if (!messages.containsKey(index)) {
      await load(index - index % batchSize);
    }

    return messages[index];
  }

  MessageDto? cachedMessageAt(int index) {
    return messages[index];
  }

  Future<void> load(int startIndex) async {
    if (messages.containsKey(startIndex)) {
      return;
    }

    final batch = await data.db.messageDao.getMessages(
      chat.id,
      startIndex,
      batchSize,
    );

    if (messages.length > batchSize) {
      messageIndexes = messageIndexes.sublist(
        messageIndexes.length - batchSize,
      );
      messages.removeWhere((key, value) => !messageIndexes.contains(key));
    }

    messages.addAll(Map.fromEntries(batch.map((m) => MapEntry(m.index, m))));
    messageIndexes.addAll(batch.map((m) => m.index));
  }
}
