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
        const Text("Order:", style: TextStyle(color: Colors.white)),
        const SizedBox(width: 19),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10.0, 0, 0, 0),
            decoration: BoxDecoration(
              color: const Color(0xFF2E2E2E),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: options[orderMode],
                dropdownColor: const Color(0xFF2E2E2E),
                style: const TextStyle(color: Colors.white),
                items:
                    options.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
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
