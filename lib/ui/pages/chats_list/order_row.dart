import 'package:flutter/material.dart';

class OrderRow extends StatefulWidget {
  final void Function(int orderMode)? onChanged;

  const OrderRow({super.key, this.onChanged});

  @override
  State<OrderRow> createState() => _OrderRowState();
}

class _OrderRowState extends State<OrderRow> {
  final options = ['Ascending', 'Descending'];
  final optionIcons = [Icons.arrow_upward, Icons.arrow_downward];

  int orderMode = 0;

  @override
  Widget build(BuildContext context) {
    /*
    DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: options[orderMode],
                dropdownColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                items:
                    options.map((String value) {
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
                    orderMode = options.indexOf(value!);

                    if (widget.onChanged != null) {
                      widget.onChanged!(orderMode);
                    }
                  });
                },
              ),
            ),
    */
    return Row(
      children: [
        const Text("Order:"),

        const SizedBox(width: 16),

        Expanded(
          child: SegmentedButton(
            segments:
                options.map((String value) {
                  int index = options.indexOf(value);

                  return ButtonSegment<int>(
                    value: index,
                    label: Text(
                      value,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    icon: Icon(optionIcons[index]),
                  );
                }).toList(),

            selected: {orderMode},

            onSelectionChanged: (Set<int> newSelection) {
              setState(() {
                orderMode = newSelection.first;
              });

              if (widget.onChanged != null) {
                widget.onChanged!(orderMode);
              }
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
