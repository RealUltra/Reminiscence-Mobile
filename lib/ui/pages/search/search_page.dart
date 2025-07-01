import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/ui/pages/search/app_bar.dart';
import 'package:reminiscence/ui/pages/search/body.dart';
import 'package:reminiscence/ui/pages/search/filter.dart';
import 'package:reminiscence/ui/pages/search/filter_type.dart';
import 'package:reminiscence/ui/components/value_controller.dart';
import 'package:reminiscence/ui/providers/session_data.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  ValueController<Map<String, Filter>> filterController = ValueController({});
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  bool isSearching = false;
  List<MessageDto> searchResults = [];

  @override
  void initState() {
    super.initState();

    filterController.addListener(() => search());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        filterController: filterController,
        searchController: searchController,
        onSearch: search,
      ),
      body: Body(
        filterController: filterController,
        scrollController: scrollController,
        isSearching: isSearching,
        searchResults: searchResults,
      ),
    );
  }

  Future<void> search() async {
    // Empty the search results
    searchResults.clear();

    // Fetch the search query
    final query = searchController.text;

    // Fetch the filters
    final filters = filterController.value.values.toList();

    // Add the search query as a filter if it isn't empty
    if (query.trim().isNotEmpty) {
      filters.add(Filter(type: FilterType.query, value: query));
    }

    // If there are no filters, do not search
    if (filters.isEmpty) {
      return;
    }

    // Remove the search results from the widget and change the results label to Searching...
    setState(() => isSearching = true);

    // Search for all matching messages
    final sessionData = Provider.of<SessionData>(context, listen: false);
    final data = sessionData.data!;
    final chat = sessionData.chat!;

    // Fetch relevant search results from the database.
    searchResults = await data.db.messageDao.searchByFilters(chat.id, filters);

    // Stop searching and show search results
    setState(() => isSearching = false);

    // Scroll to the top
    if (scrollController.hasClients) {
      await Future.delayed(const Duration(milliseconds: 200));

      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
