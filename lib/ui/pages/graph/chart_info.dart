import 'package:reminiscence/features/database/dtos/chat_dto.dart';

class ChartInfo {
  final ChatDto chat;
  bool separateParticipants;

  ChartInfo({required this.chat, this.separateParticipants = false});
}
