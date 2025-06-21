import 'dart:math';

import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';

class MessageReader {
  final ReminiscenceData data;
  final ChatDto chat;

  final batchSize = 500;

  bool loading = false;

  // its id's index in the allMessageIds list : message
  Map<int, MessageDto> cache = {};
  List<int> cacheIndexes = [];

  bool isReady = false;
  List<String> allMessageIds = [];

  MessageReader({required this.data, required this.chat});

  Future<MessageDto?> messageAt(int index) async {
    // Invalid index
    if (index < 0 || index >= chat.messageCount) {
      return null;
    }

    // Index not in currently loaded data
    if (!cache.containsKey(index)) {
      await load(index - index % batchSize);
    }

    return cache[index];
  }

  MessageDto? cachedMessageAt(int index) {
    return cache[index];
  }

  Future<void> load(int startIndex) async {
    // If it is already loading, wait for it to stop loading.
    while (loading) {
      await Future.delayed(const Duration(microseconds: 5));
    }

    // If the cache contains the required message, move on.
    if (cache.containsKey(startIndex)) {
      return;
    }

    // Start loading
    loading = true;

    // If the system messages and message ids haven't been loaded, load them.
    if (!isReady) {
      allMessageIds = await data.db.messageDao.getMessageIds(chat.id);
      isReady = true;
    }

    // Ids to retrieve
    final endIndex = min(startIndex + batchSize, allMessageIds.length);
    final targetIds = allMessageIds.sublist(startIndex, endIndex);

    // Loaded message dtos
    final batch = await data.db.messageDao.getMessages(targetIds);

    // This ensures two batches are always cached. This will remove one batch when a new one is coming in.
    if (cache.length > batchSize) {
      cacheIndexes = cacheIndexes.sublist(cacheIndexes.length - batchSize);
      cache.removeWhere((key, value) => cacheIndexes.contains(key));
    }

    // Add the new batch to the cache.
    cache.addAll(
      Map.fromEntries(
        batch.map((m) => MapEntry(allMessageIds.indexOf(m.id), m)),
      ),
    );

    // Add the new batch's indexes to the cache.
    cacheIndexes.addAll(
      targetIds.map((id) => allMessageIds.indexOf(id)).toList(),
    );

    // Stop loading
    loading = false;
  }
}
