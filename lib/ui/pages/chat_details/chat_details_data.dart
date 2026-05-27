import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/chat_details/participant_details_data.dart';

class ChatDetailsData {
  final ChatDto chat;
  final DateTime? firstMessageSentAt;
  final DateTime? lastMessageSentAt;
  final List<ParticipantDetailsData> participants;

  const ChatDetailsData({
    required this.chat,
    required this.firstMessageSentAt,
    required this.lastMessageSentAt,
    required this.participants,
  });

  int get messageCount {
    return chat.messageCount;
  }

  factory ChatDetailsData.fromTimestamps({
    required ChatDto chat,
    required List<int> messageTimestamps,
    required List<ParticipantDetailsData> participants,
  }) {
    return ChatDetailsData(
      chat: chat,
      firstMessageSentAt: _getFirstMessageSentAt(messageTimestamps),
      lastMessageSentAt: _getLastMessageSentAt(chat, messageTimestamps),
      participants: _orderParticipants(chat, participants),
    );
  }

  static DateTime? _getFirstMessageSentAt(List<int> messageTimestamps) {
    if (messageTimestamps.isEmpty) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(messageTimestamps.last);
  }

  static DateTime? _getLastMessageSentAt(
    ChatDto chat,
    List<int> messageTimestamps,
  ) {
    if (messageTimestamps.isEmpty) {
      return null;
    }

    return chat.lastMessageSentAt;
  }

  static List<ParticipantDetailsData> _orderParticipants(
    ChatDto chat,
    List<ParticipantDetailsData> participants,
  ) {
    final participantLookup = {
      for (final participant in participants) participant.name: participant,
    };

    final orderedParticipants = <ParticipantDetailsData>[];

    void addParticipant(String? name) {
      if (name == null || !participantLookup.containsKey(name)) {
        return;
      }

      orderedParticipants.add(participantLookup.remove(name)!);
    }

    addParticipant(chat.title);
    addParticipant(chat.userName);

    orderedParticipants.addAll(participantLookup.values);

    return orderedParticipants;
  }
}
