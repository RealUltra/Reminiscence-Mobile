import 'package:flutter/material.dart';

class SortSelector extends StatefulWidget {
  const SortSelector({super.key});

  @override
  State<SortSelector> createState() => _SortSelectorState();
}

class _SortSelectorState extends State<SortSelector> {
  final sortByOptions = ["Oldest First", "Newest First"];
  final sortByIcons = [Icons.arrow_upward, Icons.arrow_downward];

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      segments:
          sortByOptions.map((String text) {
            final index = sortByOptions.indexOf(text);

            return ButtonSegment<int>(
              value: index,

              label: Text(text, style: Theme.of(context).textTheme.bodyMedium),

              icon: Icon(sortByIcons[index]),
            );
          }).toList(),

      selected: {1},

      onSelectionChanged: (newSelection) {},
    );
  }
}
