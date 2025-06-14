import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/chats_list/order_row.dart';
import 'package:reminiscence/ui/pages/chats_list/sort_by_row.dart';
import 'package:reminiscence/ui/pages/chats_list/app_bar.dart';
import 'package:reminiscence/ui/pages/chats_list/search_bar.dart';

class Header extends StatelessWidget {
  final int numChats;
  final void Function(String text)? onSearchChanged;
  final void Function(int sortByMode)? onSortByChanged;
  final void Function(int orderMode)? onOrderChanged;

  const Header({
    super.key,
    required this.numChats,
    this.onSearchChanged,
    this.onSortByChanged,
    this.onOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 40.0, 12.0, 16.0),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyAppBar(numChats: numChats),
          const SizedBox(height: 10),
          MySearchBar(onChanged: onSearchChanged),
          const SizedBox(height: 10),
          SortByRow(onChanged: onSortByChanged),
          const SizedBox(height: 10),
          OrderRow(onChanged: onOrderChanged),
        ],
      ),
    );
  }
}
