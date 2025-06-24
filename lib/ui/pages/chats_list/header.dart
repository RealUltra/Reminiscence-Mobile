import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';
import 'package:reminiscence/ui/pages/chats_list/order_row.dart';
import 'package:reminiscence/ui/pages/chats_list/sort_by_row.dart';
import 'package:reminiscence/ui/pages/chats_list/search_bar.dart';

class Header extends StatelessWidget {
  final SelectionController<int> sortController;
  final SelectionController<int> orderController;
  final TextEditingController searchController;

  const Header({
    super.key,
    required this.sortController,
    required this.orderController,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MySearchBar(controller: searchController),
          const SizedBox(height: 8.0),
          SortByRow(controller: sortController),
          const SizedBox(height: 4.0),
          OrderRow(controller: orderController),
        ],
      ),
    );
  }
}
