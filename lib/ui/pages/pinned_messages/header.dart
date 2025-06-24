import 'package:flutter/material.dart';

class Header extends StatefulWidget {
  final void Function(int) onSortByChanged;

  const Header({super.key, required this.onSortByChanged});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  /*
  Container(
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
  */

  final sortByOptions = ["Oldest First", "Newest First"];
  final sortByIcons = [Icons.arrow_upward, Icons.arrow_downward];

  int sortByMode = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 12.0),

      child: Center(
        child: SegmentedButton(
          segments:
              sortByOptions.map((String value) {
                final index = sortByOptions.indexOf(value);

                return ButtonSegment<int>(
                  value: index,

                  label: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  icon: Icon(sortByIcons[index]),
                );
              }).toList(),

          selected: {sortByMode},

          onSelectionChanged: (newSelection) {
            setState(() {
              sortByMode = newSelection.first;
              widget.onSortByChanged(sortByMode);
            });
          },
        ),
      ),
    );
  }
}
