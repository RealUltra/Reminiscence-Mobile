import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';
import 'package:reminiscence/ui/pages/pinned_messages/messages_list.dart';
import 'package:reminiscence/ui/pages/pinned_messages/header.dart';

class Body extends StatefulWidget {
  final Future<void> Function() updatePinnedMessages;

  const Body({super.key, required this.updatePinnedMessages});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  ScrollController controller = ScrollController();

  SelectionController<int> sortController = SelectionController(1);

  @override
  void initState() {
    super.initState();

    sortMessages();

    sortController.addListener(() => sortMessages());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Header(sortController: sortController),

          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: MessagesList(
                scrollController: controller,
                updatePinnedMessages: widget.updatePinnedMessages,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sortMessages() {
    final pinnedMessages = Provider.of<List<MessageDto>>(
      context,
      listen: false,
    );

    setState(() {
      pinnedMessages.sort((message1, message2) {
        if (sortController.selected == 1) {
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
