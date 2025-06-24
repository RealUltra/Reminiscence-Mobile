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
        const Text("Sort By:"),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(12.0, 0, 0, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: options[sortByMode],
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
