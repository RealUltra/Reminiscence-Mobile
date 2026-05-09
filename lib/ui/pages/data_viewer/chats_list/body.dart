import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';
import 'package:reminiscence/ui/pages/data_viewer/chats_list/chats_list.dart';
import 'package:reminiscence/ui/pages/data_viewer/chats_list/header.dart';
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

  List<ChatDto> sortedChats = [];
  List<ChatDto> filteredChats = [];

  @override
  void initState() {
    super.initState();

    final sessionData = Provider.of<SessionData>(context, listen: false);
    sortedChats = List.from(sessionData.chats!);
    _sortChats();
    filteredChats = List.from(sortedChats);

    sortController.addListener(
      () => setState(() {
        _sortChats();
        _scrollToTop();
      }),
    );

    orderController.addListener(
      () => setState(() {
        _sortChats();
        _scrollToTop();
      }),
    );

    searchController.addListener(
      () => setState(() {
        _filterChatsBySearch();
        _scrollToTop();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
    );
  }

  void _filterChatsBySearch() {
    final query = searchController.text;

    filteredChats =
        sortedChats
            .where(
              (c) => c.title.toLowerCase().trim().contains(
                query.toLowerCase().trim(),
              ),
            )
            .toList();
  }

  void _sortChats() {
    for (final chatsList in [sortedChats, filteredChats]) {
      chatsList.sort((chat1, chat2) {
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
    }
  }

  void _scrollToTop() {
    if (controller.hasClients) {
      controller.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
