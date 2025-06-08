import 'package:flutter/material.dart';

class SortByRow extends StatefulWidget {
  final void Function(int sortByMode)? onChanged;

  const SortByRow({super.key, this.onChanged});

  @override
  State<SortByRow> createState() => _SortByRowState();
}

class _SortByRowState extends State<SortByRow> {
  final List<String> options = [
    'Title',
    'Number of messages',
    'Last contacted',
  ];

  int sortByMode = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("Sort By:", style: TextStyle(color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10.0, 0, 0, 0),
            decoration: BoxDecoration(
              color: const Color(0xFF2E2E2E),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: options[sortByMode],
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
                    sortByMode = options.indexOf(value!);

                    if (widget.onChanged != null) {
                      widget.onChanged!(sortByMode);
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
