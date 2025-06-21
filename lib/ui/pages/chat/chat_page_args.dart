import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';

class ChatPageArgs {
  final ReminiscenceData data;
  final ChatDto chat;
  final int startIndex;
  final bool disabled;

  const ChatPageArgs({
    required this.data,
    required this.chat,
    this.startIndex = -1,
    this.disabled = false,
  });
}
