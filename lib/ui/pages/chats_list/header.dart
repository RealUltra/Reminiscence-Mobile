import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';
import 'package:reminiscence/ui/pages/chats_list/dropdown.dart';
import 'package:reminiscence/ui/pages/chats_list/search_bar.dart';

class Header extends StatelessWidget {
  final SelectionController<int> sortController;
  final SelectionController<int> orderController;
  final TextEditingController searchController;

  final sortOptions = ['Title', 'Number of messages', 'Last contacted'];
  final orderOptions = ['Ascending', 'Descending'];

  Header({
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

          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,

            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },

            children: [
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 8.0, bottom: 8.0),
                    child: Text(
                      "Sort By:",
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Dropdown(
                      controller: sortController,
                      options: sortOptions,
                    ),
                  ),
                ],
              ),

              TableRow(
                children: [
                  Text(
                    "Order:",
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Dropdown(controller: orderController, options: orderOptions),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
