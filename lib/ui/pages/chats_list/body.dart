import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';
import 'package:reminiscence/ui/pages/chats_list/chats_list.dart';
import 'package:reminiscence/ui/pages/chats_list/header.dart';
import 'package:reminiscence/ui/providers/session_data.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  ScrollController controller = ScrollController();

  SelectionController<int> sortController = SelectionController(0);
  SelectionController<int> orderController = SelectionController(0);
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    sortController.addListener(() => setState(() {}));
    orderController.addListener(() => setState(() {}));
    searchController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final sessionData = Provider.of<SessionData>(context);
    final data = sessionData.data!;

    final filteredChats = _filterChatsBySearch(sessionData.chats!);
    _sortChats(filteredChats, scrollUp: false);

    return PopScope(
      onPopInvokedWithResult: (bool didPop, _) {
        data.closeDatabase();
      },

      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Header(
              searchController: searchController,
              sortController: sortController,
              orderController: orderController,
            ),

            ChatsList(
              chats: filteredChats,
              scrollController: controller,
              sortMode: sortController.selected,
            ),
          ],
        ),
      ),
    );
  }

  List<ChatDto> _filterChatsBySearch(List<ChatDto> chatsToFilter) {
    final sessionData = Provider.of<SessionData>(context, listen: false);
    final chats = sessionData.chats!;

    final query = searchController.text;

    chatsToFilter =
        chats
            .where(
              (c) => c.title.toLowerCase().trim().contains(
                query.toLowerCase().trim(),
              ),
            )
            .toList();

    _sortChats(chatsToFilter);

    return chatsToFilter;
  }

  void _sortChats(List<ChatDto> chats, {scrollUp = true}) {
    chats.sort((chat1, chat2) {
      if (orderController.selected == 1) {
        [chat2, chat1] = [chat1, chat2];
      }

      if (sortController.selected == 0) {
        return chat1.title.toLowerCase().compareTo(chat2.title.toLowerCase());
      } else if (sortController.selected == 1) {
        return chat1.messageCount.compareTo(chat2.messageCount);
      } else {
        return chat1.lastMessageSentAt.compareTo(chat2.lastMessageSentAt);
      }
    });

    if (scrollUp && controller.hasClients) {
      controller.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
