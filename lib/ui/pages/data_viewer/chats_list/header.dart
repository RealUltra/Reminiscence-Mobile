import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';
import 'package:reminiscence/ui/components/toggle_button.dart';
import 'package:reminiscence/ui/pages/data_viewer/chats_list/search_bar.dart';

class Header extends StatelessWidget {
  final SelectionController<int> sortController;
  final SelectionController<int> orderController;
  final TextEditingController searchController;

  final sortOptions = ['Title', 'Number of messages', 'Last contacted'];
  final orderOptions = ['Ascending', 'Descending'];
  final sortIcons = [
    Icons.sort_by_alpha_rounded,
    Icons.message_rounded,
    Icons.access_time_rounded,
  ];
  final orderIcons = [Icons.arrow_upward_rounded, Icons.arrow_downward_rounded];

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
                    child: ToggleButton(
                      values:
                          sortOptions
                              .map(
                                (option) => ToggleButtonValue(
                                  icon: sortIcons[sortOptions.indexOf(option)],
                                  title: option,
                                ),
                              )
                              .toList(),
                      controller: sortController,
                      decoration: _buildToggleButtonDecoration(context),
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

                  ToggleButton(
                    values:
                        orderOptions
                            .map(
                              (option) => ToggleButtonValue(
                                icon: orderIcons[orderOptions.indexOf(option)],
                                title: option,
                              ),
                            )
                            .toList(),
                    controller: orderController,
                    decoration: _buildToggleButtonDecoration(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildToggleButtonDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }
}
