class ChatDto {
  final int id;
  final String title;
  final String? userName;
  final int messageCount;
  final DateTime lastMessageSentAt;

  const ChatDto({
    required this.id,
    required this.title,
    required this.userName,
    required this.messageCount,
    required this.lastMessageSentAt,
  });
}
