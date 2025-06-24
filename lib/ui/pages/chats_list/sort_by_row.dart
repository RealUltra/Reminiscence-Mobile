import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';

class SortByRow extends StatefulWidget {
  final SelectionController<int> controller;

  const SortByRow({super.key, required this.controller});

  @override
  State<SortByRow> createState() => _SortByRowState();
}

class _SortByRowState extends State<SortByRow> {
  final options = ['Title', 'Number of messages', 'Last contacted'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("Sort By:"),

        const SizedBox(width: 8),

        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 12.0, right: 8.0),

            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
            ),

            child: DropdownButton<int>(
              value: widget.controller.selected,

              dropdownColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,

              underline: Container(),
              isExpanded: true,

              items:
                  options.map((String text) {
                    final index = options.indexOf(text);

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
                  widget.controller.selected =
                      value ?? widget.controller.selected;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
