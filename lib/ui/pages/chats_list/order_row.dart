import 'package:flutter/material.dart';

class OrderRow extends StatefulWidget {
  final void Function(int orderMode)? onChanged;

  const OrderRow({super.key, this.onChanged});

  @override
  State<OrderRow> createState() => _OrderRowState();
}

class _OrderRowState extends State<OrderRow> {
  final List<String> options = ['Ascending', 'Descending'];

  int orderMode = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("Order:"),
        const SizedBox(width: 19),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10.0, 0, 0, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButtonHideUnderline(
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
          ),
        ),
      ],
    );
  }
}
