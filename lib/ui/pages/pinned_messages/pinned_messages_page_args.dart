import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';

class PinnedMessagesPageArgs {
  final ReminiscenceData data;
  final ChatDto chat;

  const PinnedMessagesPageArgs({required this.data, required this.chat});
}
