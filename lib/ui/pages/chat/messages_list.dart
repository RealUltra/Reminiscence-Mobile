import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/ui/pages/chat/chat_page_args.dart';
import 'package:reminiscence/ui/pages/chat/message_widget.dart';
import 'package:reminiscence/ui/providers/session_data.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MessagesList extends StatefulWidget {
  const MessagesList({super.key});

  @override
  State<MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  bool isReady = false;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();

  bool showScrollToBottom = false;

  @override
  void initState() {
    super.initState();

    itemPositionsListener.itemPositions.addListener(onScroll);

    initMessageReader();
  }

  Future<void> initMessageReader() async {
    final initialMessageId = Provider.of<String?>(context, listen: false);

    final sessionData = Provider.of<SessionData>(context, listen: false);
    final chat = sessionData.chat!;

    if (sessionData.messageReader == null ||
        sessionData.messageReader!.chat.id != chat.id) {
      await sessionData.loadMessageReader();
    }

    final messageReader = sessionData.messageReader!;

    if (initialMessageId != null) {
      final index = messageReader.indexOf(initialMessageId);
      await messageReader.load(index);
    } else {
      await messageReader.load(0);
    }

    setState(() => isReady = true);

    await initialJump();
  }

  Future<void> initialJump() async {
    final initialMessageId = Provider.of<String?>(context, listen: false);

    if (initialMessageId == null) {
      return;
    }

    final sessionData = Provider.of<SessionData>(context, listen: false);
    final messageReader = sessionData.messageReader!;

    while (!itemScrollController.isAttached || !messageReader.ready) {
      await Future.delayed(const Duration(microseconds: 5));
    }

    final index = messageReader.indexOf(initialMessageId);

    if (index <= 0) {
      return;
    }

    itemScrollController.jumpTo(index: index, alignment: 0.5);
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return Container();
    }

    final sessionData = Provider.of<SessionData>(context);
    final data = sessionData.data!;
    final chat = sessionData.chat!;
    final messageReader = sessionData.messageReader!;

    final initialMessageId = Provider.of<String?>(context);
    final disabled = Provider.of<bool>(context);

    return Stack(
      children: [
        ScrollablePositionedList.builder(
          itemCount: chat.messageCount,
          reverse: true,
          padding: EdgeInsets.symmetric(vertical: 16),
          minCacheExtent: 1000.0,

          itemScrollController: itemScrollController,
          scrollOffsetController: scrollOffsetController,
          itemPositionsListener: itemPositionsListener,
          scrollOffsetListener: scrollOffsetListener,

          itemBuilder: (BuildContext context, int index) {
            // Check if the message has already been loaded
            final message = messageReader.cachedMessageAt(index);
            final previousMessage = messageReader.cachedMessageAt(index + 1);

            if (message != null && previousMessage != null) {
              return MessageWidget(
                data: data,
                userName: chat.userName,
                message: message,
                previousMessage: previousMessage,
                startHighlighted: message.id == initialMessageId,
                refreshWidget: _refreshWidget,
              );
            }

            // Load the message if it is not already cached.
            return FutureBuilder<List<MessageDto?>>(
              future:
                  (() async {
                    final message = await messageReader.messageAt(index);
                    final previousMessage = await messageReader.messageAt(
                      index + 1,
                    );
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
                    data: data,
                    userName: chat.userName,
                    message: messages[0],
                    previousMessage: messages[1],
                    startHighlighted: messages[0].id == initialMessageId,
                    refreshWidget: _refreshWidget,
                  );
                }
              },
            );
          },
        ),

        Visibility(
          visible: !disabled && showScrollToBottom,

          child: Positioned(
            bottom: 16.0,
            left: 0,
            right: 0,

            child: Center(
              child: FloatingActionButton(
                onPressed: scrollToBottom,
                child: const Icon(Icons.arrow_downward),
              ),
            ),
          ),
        ),

        Visibility(
          visible: disabled,

          child: Positioned(
            bottom: 0.0,
            left: 0,
            right: 0,

            child: GestureDetector(
              onTap: () => jumpHere(context),

              child: Container(
                padding: EdgeInsets.all(12.0),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Center(
                  child: Text(
                    "Jump Here",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void onScroll() {
    int bottomItemIndex = itemPositionsListener.itemPositions.value.first.index;

    final threshold = 20;
    final showFAB = bottomItemIndex > threshold;

    if (showFAB != showScrollToBottom) {
      setState(() {
        showScrollToBottom = showFAB;
      });
    }
  }

  void scrollToBottom() {
    itemScrollController.scrollTo(
      index: 0,
      duration: const Duration(milliseconds: 300),
      alignment: 0.5,
    );
  }

  Future<void> jumpHere(BuildContext context) async {
    final initialMessageId = Provider.of<String?>(context, listen: false);

    await Navigator.of(context).pushNamedAndRemoveUntil(
      "/chat",
      ModalRoute.withName("/chats"),
      arguments: ChatPageArgs(
        initialMessageId: initialMessageId,
        disabled: false,
      ),
    );
  }

  Future<void> _refreshWidget() async {
    final sessionData = Provider.of<SessionData>(context, listen: false);
    sessionData.loadMessageReader();

    scrollToBottom();

    setState(() {});
  }
}
