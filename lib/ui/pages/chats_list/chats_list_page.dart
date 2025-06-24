import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reminiscence/ui/pages/chats_list/app_bar.dart';
import 'package:reminiscence/ui/pages/chats_list/body.dart';
import 'package:reminiscence/ui/providers/session_data.dart';

class ChatsListPage extends StatefulWidget {
  const ChatsListPage({super.key});

  @override
  State<ChatsListPage> createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    initChats();
  }

  Future<void> initChats() async {
    final sessionData = Provider.of<SessionData>(context, listen: false);
    await sessionData.loadChats();
    setState(() => isReady = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return Scaffold();
    }
    return Scaffold(appBar: MyAppBar(), body: Body());
  }
}
