import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/graph/app_bar.dart';
import 'package:reminiscence/ui/pages/graph/body.dart';

class GraphPage extends StatelessWidget {
  final ReminiscenceData data;
  final ChatDto chat;

  const GraphPage({super.key, required this.data, required this.chat});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ReminiscenceData>.value(value: data),
        Provider<ChatDto>.value(value: chat),
      ],
      child: Scaffold(appBar: MyAppBar(), body: Body()),
    );
  }
}
