import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';

class Dropdown extends StatefulWidget {
  final SelectionController<int> controller;
  final List<String> options;

  const Dropdown({super.key, required this.controller, required this.options});

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12.0, right: 8.0),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),

      child: DropdownButton<int>(
        value: widget.controller.selected,

        dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,

        underline: Container(),
        isExpanded: true,

        items:
            widget.options.map((String text) {
              final index = widget.options.indexOf(text);

              return DropdownMenuItem<int>(
                value: index,
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }).toList(),

        onChanged: (value) {
          setState(() {
            widget.controller.selected = value ?? widget.controller.selected;
          });
        },
      ),
    );
  }
}
