import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/ui/pages/pinned_messages/app_bar.dart';
import 'package:reminiscence/ui/pages/pinned_messages/body.dart';
import 'package:reminiscence/ui/providers/session_data.dart';

class PinnedMessagesPage extends StatefulWidget {
  const PinnedMessagesPage({super.key});

  @override
  State<PinnedMessagesPage> createState() => _PinnedMessagesPageState();
}

class _PinnedMessagesPageState extends State<PinnedMessagesPage> {
  bool isReady = false;
  List<MessageDto> pinnedMessages = [];

  @override
  void initState() {
    super.initState();

    updatePinnedMessages();
  }

  Future<void> updatePinnedMessages() async {
    final sessionData = Provider.of<SessionData>(context, listen: false);
    final data = sessionData.data!;
    final chat = sessionData.chat!;

    pinnedMessages = await data.db.messageDao.getPinned(chat.id);
    setState(() {
      isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return Scaffold();
    }

    return Provider<List<MessageDto>>.value(
      value: pinnedMessages,
      child: Scaffold(
        appBar: MyAppBar(),
        body: Body(updatePinnedMessages: updatePinnedMessages),
      ),
    );
  }
}
