import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';

class Header extends StatefulWidget {
  final SelectionController<int> sortController;

  const Header({super.key, required this.sortController});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final sortByOptions = ["Oldest", "Newest"];
  final sortByIcons = [Icons.arrow_upward, Icons.arrow_downward];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),

      child: Center(
        child: SegmentedButton(
          segments:
              sortByOptions.map((String text) {
                final index = sortByOptions.indexOf(text);

                return ButtonSegment<int>(
                  value: index,

                  label: Text(
                    text,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  icon: Icon(sortByIcons[index]),
                );
              }).toList(),

          selected: {widget.sortController.selected},

          onSelectionChanged: (newSelection) {
            setState(() {
              widget.sortController.selected = newSelection.first;
            });
          },
        ),
      ),
    );
  }
}
