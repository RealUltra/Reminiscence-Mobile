import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/ui/pages/chat/message_reader.dart';
import 'package:reminiscence/ui/pages/chat/message_widget.dart';

class MessagesList extends StatefulWidget {
  final ReminiscenceData data;
  final ChatDto chat;
  final MessageReader messageReader;

  const MessagesList({
    super.key,
    required this.data,
    required this.chat,
    required this.messageReader,
  });

  @override
  State<MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  final ScrollController controller = ScrollController();

  bool showScrollToBottom = false;

  @override
  void initState() {
    super.initState();

    controller.addListener(onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          itemCount: widget.chat.messageCount,
          controller: controller,
          reverse: true,
          padding: EdgeInsets.symmetric(vertical: 16),
          cacheExtent: 1000.0,

          itemBuilder: (BuildContext context, int index) {
            // Check if the message has already been loaded
            final message = widget.messageReader.cachedMessageAt(index);
            final previousMessage = widget.messageReader.cachedMessageAt(
              index + 1,
            );

            if (message != null && previousMessage != null) {
              return MessageWidget(
                data: widget.data,
                userName: widget.chat.userName,
                message: message,
                previousMessage: previousMessage,
              );
            }

            // Load the message if it is not already cached.
            return FutureBuilder<List<MessageDto?>>(
              future:
                  (() async {
                    final message = await widget.messageReader.messageAt(index);
                    final previousMessage = await widget.messageReader
                        .messageAt(index + 1);
                    return [message, previousMessage];
                  })(),

              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                final emptyWidget = const SizedBox(height: 12);
                final errorWidget = Text(
                  "Error at index $index: ${snapshot.error}",
                  style: TextStyle(color: Colors.red),
                );

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return emptyWidget;
                } else if (snapshot.hasError) {
                  return errorWidget;
                } else if (!snapshot.hasData) {
                  return Text("No data");
                } else {
                  final messages = snapshot.data;

                  if (messages[0] == null) {
                    return Text("message was null; index: $index");
                  }

                  return MessageWidget(
                    data: widget.data,
                    userName: widget.chat.userName,
                    message: messages[0],
                    previousMessage: messages[1],
                  );
                }
              },
            );
          },
        ),

        showScrollToBottom
            ? Positioned(
              bottom: 12.0,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  onPressed: () => controller.jumpTo(0.0),
                  child: const Icon(Icons.arrow_downward),
                ),
              ),
            )
            : Container(),
      ],
    );
  }

  void onScroll() {
    // Show the scroll to the bottom button or hide it.
    final threshold = 600;
    final currentScroll = controller.position.pixels;
    final showFAB = currentScroll > threshold;

    if (showFAB != showScrollToBottom) {
      setState(() {
        showScrollToBottom = showFAB;
      });
    }
  }
}
