import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';
import 'package:reminiscence/ui/pages/search/messages_list.dart';
import 'package:reminiscence/ui/pages/search/filter.dart';
import 'package:reminiscence/ui/pages/search/header.dart';
import 'package:reminiscence/ui/components/value_controller.dart';
import 'package:reminiscence/ui/pages/search/quick_searches/quick_search_section.dart';

class Body extends StatefulWidget {
  final TextEditingController searchController;
  final ValueController<Map<String, Filter>> filterController;
  final ScrollController scrollController;
  final bool isSearching;
  final List<MessageDto> searchResults;

  const Body({
    super.key,
    required this.searchController,
    required this.filterController,
    required this.scrollController,
    required this.isSearching,
    required this.searchResults,
  });

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final SelectionController<int> sortController = SelectionController(1);

  @override
  void initState() {
    super.initState();

    sortController.addListener(() async {
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 200));
      scrollToTop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedMessages = sortMessages();

    final showQuickSearches =
        widget.searchController.text.isEmpty &&
        widget.filterController.value.isEmpty;

    return SafeArea(
      child: Column(
        children: [
          Header(
            filterController: widget.filterController,
            sortController: sortController,
            isSearching: widget.isSearching,
            numResults: widget.searchResults.length,
          ),

          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child:
                  showQuickSearches
                      ? QuickSearchSection()
                      : MessagesList(
                        scrollController: widget.scrollController,
                        messages: sortedMessages,
                      ),
            ),
          ),
        ],
      ),
    );
  }

  List<MessageDto> sortMessages() {
    final sortedMessages = widget.searchResults.sorted((message1, message2) {
      if (sortController.selected == 1) {
        [message1, message2] = [message2, message1];
      }
      return message1.sentAt.compareTo(message2.sentAt);
    });

    return sortedMessages;
  }

  void scrollToTop() {
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
