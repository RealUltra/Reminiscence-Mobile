import 'package:flutter/material.dart';

import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/chats_list/chats_list.dart';
import 'package:reminiscence/ui/pages/chats_list/header.dart';

class Body extends StatefulWidget {
  final ReminiscenceData data;

  const Body(this.data, {super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool _isLoading = true;

  final chats = <ChatDto>[];
  List<ChatDto> filteredChats = [];

  ScrollController? controller;

  int sortByMode = 0;
  int orderMode = 0;

  @override
  void initState() {
    super.initState();

    _fetchData();
  }

  Future<void> _fetchData() async {
    final chatDtos = await widget.data.db.chatDao.getChatDtos();

    chats.clear();
    chats.addAll(chatDtos);

    filteredChats.clear();
    filteredChats.addAll(chatDtos);

    _sortChats();

    controller = ScrollController();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container();
    }

    return PopScope(
      onPopInvokedWithResult: (bool didPop, _) {
        widget.data.closeDatabase();
      },

      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Header(
              numChats: chats.length,

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

  void _sortChats() {
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

    if (controller != null) {
      controller!.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
