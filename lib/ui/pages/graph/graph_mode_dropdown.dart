import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/graph/dropdown_controller.dart';

class GraphModeDropdown extends StatefulWidget {
  final DropdownController controller;

  const GraphModeDropdown({super.key, required this.controller});

  @override
  State<GraphModeDropdown> createState() => _GraphModeDropdownState();
}

class _GraphModeDropdownState extends State<GraphModeDropdown> {
  final graphModeOptions = ["Daily", "Monthly", "Yearly"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
      width: 150.0,

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: graphModeOptions[widget.controller.selected],
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          items:
              graphModeOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }).toList(),

          onChanged: (value) {
            setState(() {
              widget.controller.selected = graphModeOptions.indexOf(value!);
            });
          },
        ),
      ),
    );
  }
}
