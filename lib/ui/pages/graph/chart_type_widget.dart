import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/graph/selection_controller.dart';

class ChartTypeWidget extends StatefulWidget {
  final SelectionController controller;

  const ChartTypeWidget({super.key, required this.controller});

  @override
  State<ChartTypeWidget> createState() => _ChartTypeWidgetState();
}

class _ChartTypeWidgetState extends State<ChartTypeWidget> {
  final chartTypeOptions = ["Line", "Bar"];
  final chartTypeIcons = [Icons.show_chart, Icons.bar_chart];

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      segments:
          chartTypeOptions.map((text) {
            final index = chartTypeOptions.indexOf(text);

            return ButtonSegment<int>(
              value: index,
              label: Text(text),
              icon: Icon(chartTypeIcons[index]),
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
