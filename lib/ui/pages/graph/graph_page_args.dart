import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';

class GraphPageArgs {
  final ReminiscenceData data;
  final ChatDto chat;

  const GraphPageArgs({required this.data, required this.chat});
}
