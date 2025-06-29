import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';
import 'package:reminiscence/ui/pages/search/filter.dart';
import 'package:reminiscence/ui/pages/search/filters_layout.dart';
import 'package:reminiscence/ui/pages/search/results_label.dart';
import 'package:reminiscence/ui/pages/search/sort_selector.dart';
import 'package:reminiscence/ui/pages/search/value_controller.dart';

class Header extends StatefulWidget {
  final ValueController<Map<String, Filter>> filterController;
  final SelectionController<int> sortController;
  final bool isSearching;
  final int numResults;

  const Header({
    super.key,
    required this.filterController,
    required this.sortController,
    required this.isSearching,
    required this.numResults,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      width: double.infinity,
      padding: EdgeInsets.only(top: 12.0, bottom: 12.0),

      child: Column(
        children: [
          if (widget.filterController.value.isNotEmpty) ...{
            FiltersLayout(controller: widget.filterController),

            const SizedBox(height: 12.0),
            const Divider(height: 1.0),
            SizedBox(height: 12.0),
          },

          SortSelector(controller: widget.sortController),

          ResultsLabel(
            isSearching: widget.isSearching,
            numResults: widget.numResults,
          ),
        ],
      ),
    );
  }
}
