import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/ui/pages/pinned_messages/app_bar.dart';
import 'package:reminiscence/ui/pages/pinned_messages/body.dart';

class PinnedMessagesPage extends StatefulWidget {
  final ReminiscenceData data;
  final ChatDto chat;

  const PinnedMessagesPage({super.key, required this.data, required this.chat});

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
    pinnedMessages = await widget.data.db.messageDao.getPinned(widget.chat.id);
    setState(() {
      isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return Scaffold();
    }

    return Scaffold(
      appBar: MyAppBar(pinnedMessages.length),
      body: Body(
        data: widget.data,
        chat: widget.chat,
        pinnedMessages: pinnedMessages,
      ),
    );
  }
}
