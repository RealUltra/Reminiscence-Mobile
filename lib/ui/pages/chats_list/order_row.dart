import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';

class OrderRow extends StatefulWidget {
  final SelectionController<int> controller;

  const OrderRow({super.key, required this.controller});

  @override
  State<OrderRow> createState() => _OrderRowState();
}

class _OrderRowState extends State<OrderRow> {
  final options = ['Ascending', 'Descending'];
  final optionIcons = [Icons.arrow_upward, Icons.arrow_downward];

  int orderMode = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("Order:"),

        const SizedBox(width: 16),

        Expanded(
          child: SegmentedButton(
            segments:
                options.map((String text) {
                  int index = options.indexOf(text);

                  return ButtonSegment<int>(
                    value: index,
                    label: Text(
                      text,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    icon: Icon(optionIcons[index]),
                  );
                }).toList(),

            selected: {widget.controller.selected},

            onSelectionChanged: (Set<int> newSelection) {
              setState(() {
                widget.controller.selected = newSelection.first;
              });
            },

            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return null;
                }
                return Theme.of(context).colorScheme.surfaceContainerHighest;
              }),

              foregroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.onSurface,
              ),

              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
