import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/chats_list/app_bar.dart';
import 'package:reminiscence/ui/pages/chats_list/body.dart';

class ChatsListPage extends StatefulWidget {
  final ReminiscenceData data;

  const ChatsListPage(this.data, {super.key});

  @override
  State<ChatsListPage> createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  final List<ChatDto> chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _fetchData();
  }

  Future<void> _fetchData() async {
    final chatDtos = await widget.data.db.chatDao.getChatDtos();

    chats.clear();
    chats.addAll(chatDtos);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold();
    }

    return MultiProvider(
      providers: [
        Provider<ReminiscenceData>.value(value: widget.data),
        Provider<List<ChatDto>>.value(value: chats),
      ],
      child: Scaffold(appBar: MyAppBar(), body: Body()),
    );
  }
}
