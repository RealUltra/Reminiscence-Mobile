import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/chat/message_reader.dart';
import 'package:reminiscence/ui/pages/chat/messages_list.dart';

class Body extends StatefulWidget {
  final ReminiscenceData data;
  final ChatDto chat;
  final int startIndex;
  final bool disabled;

  const Body({
    super.key,
    required this.data,
    required this.chat,
    required this.startIndex,
    required this.disabled,
  });

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool isReady = true;
  late final MessageReader messageReader;

  @override
  void initState() {
    super.initState();

    messageReader = MessageReader(data: widget.data, chat: widget.chat);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Visibility(
          visible: isReady,
          child: MessagesList(
            data: widget.data,
            chat: widget.chat,
            messageReader: messageReader,
            startIndex: widget.startIndex,
            disabled: widget.disabled,
          ),
        ),
      ),
    );
  }
}
