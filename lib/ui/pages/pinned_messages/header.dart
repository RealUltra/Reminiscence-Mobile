import 'package:flutter/material.dart';

class Header extends StatefulWidget {
  final void Function(int) onSortByChanged;

  const Header({super.key, required this.onSortByChanged});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final List<String> sortByOptions = ["Old", "New"];
  int sortByMode = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),

      child: Row(
        children: [
          const Text("Sort By:"),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10.0, 0, 0, 0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: sortByOptions[sortByMode],
                  dropdownColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  items:
                      sortByOptions.map((String value) {
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
                      sortByMode = sortByOptions.indexOf(value!);
                      widget.onSortByChanged(sortByMode);
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
