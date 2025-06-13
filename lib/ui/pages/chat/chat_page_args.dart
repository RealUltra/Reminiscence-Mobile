import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';

class ChatPageArgs {
  final ReminiscenceData data;
  final ChatDto chat;

  const ChatPageArgs({required this.data, required this.chat});
}
