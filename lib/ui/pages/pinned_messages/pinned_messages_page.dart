import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    return MultiProvider(
      providers: [
        Provider<ReminiscenceData>.value(value: widget.data),
        Provider<ChatDto>.value(value: widget.chat),
        Provider<List<MessageDto>>.value(value: pinnedMessages),
      ],

      child: Scaffold(
        appBar: MyAppBar(),
        body: Body(updatePinnedMessages: updatePinnedMessages),
      ),
    );
  }
}
