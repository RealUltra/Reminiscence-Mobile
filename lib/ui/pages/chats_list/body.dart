import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reminiscence/features/database/dtos/chat_dto.dart';
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

  String searchQuery = "";

  int sortByMode = 0;
  int orderMode = 0;

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
              onSearchChanged: (query) => setState(() => searchQuery = query),

              onSortByChanged: (m) {
                setState(() {
                  sortByMode = m;
                });
              },

              onOrderChanged: (m) {
                setState(() {
                  orderMode = m;
                });
              },
            ),

            ChatsList(
              chats: filteredChats,
              scrollController: controller,
              sortByMode: sortByMode,
            ),
          ],
        ),
      ),
    );
  }

  List<ChatDto> _filterChatsBySearch(List<ChatDto> chatsToFilter) {
    final sessionData = Provider.of<SessionData>(context, listen: false);
    final chats = sessionData.chats!;

    chatsToFilter =
        chats
            .where(
              (c) => c.title.toLowerCase().trim().contains(
                searchQuery.toLowerCase().trim(),
              ),
            )
            .toList();

    _sortChats(chatsToFilter);

    return chatsToFilter;
  }

  void _sortChats(List<ChatDto> chats, {scrollUp = true}) {
    chats.sort((chat1, chat2) {
      if (orderMode == 1) {
        [chat2, chat1] = [chat1, chat2];
      }

      if (sortByMode == 0) {
        return chat1.title.toLowerCase().compareTo(chat2.title.toLowerCase());
      } else if (sortByMode == 1) {
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
