import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/ui/pages/pinned_messages/messages_list.dart';
import 'package:reminiscence/ui/pages/pinned_messages/header.dart';

class Body extends StatefulWidget {
  final ReminiscenceData data;
  final ChatDto chat;
  final List<MessageDto> pinnedMessages;

  const Body({
    super.key,
    required this.data,
    required this.chat,
    required this.pinnedMessages,
  });

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    sortMessages(1);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Header(onSortByChanged: sortMessages),

          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: MessagesList(
                data: widget.data,
                chat: widget.chat,
                pinnedMessages: widget.pinnedMessages,
                scrollController: controller,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sortMessages(int sortByMode) {
    setState(() {
      widget.pinnedMessages.sort((message1, message2) {
        if (sortByMode == 1) {
          [message1, message2] = [message2, message1];
        }
        return message1.sentAt.compareTo(message2.sentAt);
      });

      controller.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }
}
