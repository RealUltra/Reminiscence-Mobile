import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/chats_list/chats_list.dart';
import 'package:reminiscence/ui/pages/chats_list/header.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  List<ChatDto> filteredChats = [];

  ScrollController controller = ScrollController();

  int sortByMode = 0;
  int orderMode = 0;

  @override
  void initState() {
    super.initState();

    filteredChats = Provider.of<List<ChatDto>>(context, listen: false);

    setState(() {
      _sortChats(scrollUp: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ReminiscenceData>(context, listen: false);

    return PopScope(
      onPopInvokedWithResult: (bool didPop, _) {
        data.closeDatabase();
      },

      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Header(
              onSearchChanged: _filterChatsBySearch,

              onSortByChanged: (m) {
                setState(() {
                  sortByMode = m;
                  _sortChats();
                });
              },

              onOrderChanged: (m) {
                setState(() {
                  orderMode = m;
                  _sortChats();
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

  void _filterChatsBySearch(String text) {
    final chats = Provider.of<List<ChatDto>>(context, listen: false);

    setState(() {
      filteredChats =
          chats
              .where(
                (c) => c.title.toLowerCase().trim().contains(
                  text.toLowerCase().trim(),
                ),
              )
              .toList();

      _sortChats();
    });
  }

  void _sortChats({scrollUp = true}) {
    filteredChats.sort((chat1, chat2) {
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

    if (scrollUp) {
      controller.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
