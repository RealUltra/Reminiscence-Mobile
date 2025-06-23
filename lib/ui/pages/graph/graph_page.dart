import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/graph/app_bar.dart';
import 'package:reminiscence/ui/pages/graph/body.dart';
import 'package:reminiscence/ui/pages/graph/charts_notifier.dart';

class GraphPage extends StatefulWidget {
  final ReminiscenceData data;
  final ChatDto chat;

  const GraphPage({super.key, required this.data, required this.chat});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  List<ChatDto> chats = [];

  @override
  void initState() {
    super.initState();

    fetchChats();
  }

  Future<void> fetchChats() async {
    chats.clear();
    chats = await widget.data.db.chatDao.getChatDtos();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ReminiscenceData>.value(value: widget.data),
        Provider<ChatDto>.value(value: widget.chat),
        Provider<List<ChatDto>>.value(value: chats),
        ChangeNotifierProvider(create: (_) => ChartsNotifier()),
      ],
      child: Scaffold(appBar: MyAppBar(), body: Body()),
    );
  }
}
