import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/chats_list/order_row.dart';
import 'package:reminiscence/ui/pages/chats_list/sort_by_row.dart';
import 'package:reminiscence/ui/pages/chats_list/search_bar.dart';

class Header extends StatelessWidget {
  final void Function(String text)? onSearchChanged;
  final void Function(int sortByMode)? onSortByChanged;
  final void Function(int orderMode)? onOrderChanged;

  const Header({
    super.key,
    this.onSearchChanged,
    this.onSortByChanged,
    this.onOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MySearchBar(onChanged: onSearchChanged),
          const SizedBox(height: 8.0),
          SortByRow(onChanged: onSortByChanged),
          const SizedBox(height: 4.0),
          OrderRow(onChanged: onOrderChanged),
        ],
      ),
    );
  }
}
