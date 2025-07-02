import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/daos/message_column.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';

class MessageReader {
  final ReminiscenceData data;
  final ChatDto chat;

  final batchSize = 500;
  final cacheSize = 1000;

  bool ready = false;
  bool loading = false;

  // its id's index in the allMessageIds list : message
  Map<int, MessageDto> cache = {};

  // All the ids in cache in insertion order.
  List<int> cacheKeyOrder = [];

  // message id : index
  final messageIdLookup = <String, int>{};

  // The timestamps of every message that isn't a system message.
  final messageTimestamps = <int>[];

  MessageReader({required this.data, required this.chat});

  Future<void> initialize() async {
    loading = true;

    final messagesMetadata = await data.db.messageDao.getAllMessages(
      chat.id,
      columns: [MessageColumn.id, MessageColumn.sentAt],
    );

    cache.clear();
    cacheKeyOrder.clear();

    messageIdLookup.clear();
    messageTimestamps.clear();

    for (int i = 0; i < messagesMetadata.length; i++) {
      final message = messagesMetadata[i];
      messageIdLookup[message.id] = i;
      messageTimestamps.add(message.sentAt);
    }

    ready = true;
    loading = false;
  }

  int indexOf(String messageId) {
    return messageIdLookup[messageId] ?? -1;
  }

  Future<MessageDto?> messageAt(int index) async {
    // Invalid index
    if (index < 0 || index >= chat.messageCount) {
      return null;
    }

    // Index not in currently loaded data
    if (!cache.containsKey(index)) {
      await load(index);
    }

    return cache[index];
  }

  MessageDto? cachedMessageAt(int index) {
    return cache[index];
  }

  Future<void> load(int index) async {
    final startIndex = index - index % batchSize;

    // If it is already loading, wait for it to stop loading.
    while (loading) {
      await Future.delayed(const Duration(microseconds: 5));
    }

    // If the cache contains the target index, move on.
    if (cache.containsKey(index)) {
      return;
    }

    // Start loading
    loading = true;

    // If the system messages and message ids haven't been loaded, load them.
    if (!ready) {
      initialize();
    }

    // Load a batch of messages
    final batch = await data.db.messageDao.getMessages(
      chat.id,
      messageTimestamps[startIndex],
      batchSize,
    );

    // Add the new batch to the cache.
    cache.addAll(
      Map.fromEntries(batch.map((m) => MapEntry(messageIdLookup[m.id]!, m))),
    );

    // Add the new batch's indexes to the cache.
    final batchIndicies = batch.map((m) => messageIdLookup[m.id]!).toList();

    // Remove each index from the order if it was previously loaded, and readd it to the order at the very end of it.
    for (final index in batchIndicies) {
      cacheKeyOrder.remove(index);
      cacheKeyOrder.add(index);
    }

    // If the cache exceeds its limit, remove the oldest additions to the cache.
    if (cache.length > cacheSize) {
      final numKeysToRemove = cache.length - cacheSize;
      final keysToRemove = cacheKeyOrder.sublist(0, numKeysToRemove);
      cache.removeWhere((idx, m) => keysToRemove.contains(idx));
      cacheKeyOrder.removeRange(0, numKeysToRemove);
    }

    // Stop loading
    loading = false;
  }
}
