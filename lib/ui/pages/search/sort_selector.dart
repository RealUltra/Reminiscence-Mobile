import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';

class SortSelector extends StatefulWidget {
  final SelectionController<int> controller;

  const SortSelector({super.key, required this.controller});

  @override
  State<SortSelector> createState() => _SortSelectorState();
}

class _SortSelectorState extends State<SortSelector> {
  final sortByOptions = ["Oldest", "Newest"];
  final sortByIcons = [Icons.arrow_upward, Icons.arrow_downward];

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: SegmentedButton(
        expandedInsets: EdgeInsets.zero,

        segments:
            sortByOptions.map((String text) {
              final index = sortByOptions.indexOf(text);

              return ButtonSegment<int>(
                value: index,

                label: Text(text, style: Theme.of(context).textTheme.bodySmall),

                icon: Icon(sortByIcons[index]),
              );
            }).toList(),

        selected: {widget.controller.selected},

        onSelectionChanged: (newSelection) {
          setState(() {
            widget.controller.selected = newSelection.first;
          });
        },
      ),
    );
  }
}
