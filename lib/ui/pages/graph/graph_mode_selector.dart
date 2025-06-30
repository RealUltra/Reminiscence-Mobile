import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';

class GraphModeSelector extends StatefulWidget {
  final SelectionController<int> controller;

  const GraphModeSelector({super.key, required this.controller});

  @override
  State<GraphModeSelector> createState() => _GraphModeSelectorState();
}

class _GraphModeSelectorState extends State<GraphModeSelector> {
  final graphModeOptions = ["Daily", "Monthly", "Yearly"];
  final graphModeIcons = [
    Icons.calendar_view_day,
    Icons.calendar_view_month,
    Icons.calendar_today,
  ];

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      segments:
          graphModeOptions.map((text) {
            final index = graphModeOptions.indexOf(text);

            return ButtonSegment<int>(
              value: index,
              label: Text(text, style: Theme.of(context).textTheme.labelSmall),
              icon: Icon(graphModeIcons[index]),
            );
          }).toList(),

      selected: {widget.controller.selected},

      onSelectionChanged: (Set<int> newSelection) {
        setState(() {
          widget.controller.selected = newSelection.first;
        });
      },
    );
  }
}
