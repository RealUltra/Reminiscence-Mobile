import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/graph/dropdown_controller.dart';

class GraphDetailsWidget extends StatefulWidget {
  final int graphMode;
  final List<int> timestamps;
  final DropdownController controller;

  const GraphDetailsWidget({
    super.key,
    required this.graphMode,
    required this.timestamps,
    required this.controller,
  });

  @override
  State<GraphDetailsWidget> createState() => _GraphDetailsWidgetState();
}

class _GraphDetailsWidgetState extends State<GraphDetailsWidget> {
  List<String> yearOptions = [];
  List<String> monthOptions = [];

  @override
  void initState() {
    super.initState();

    yearOptions = _getYears().map((y) => y.toString()).toList();
    monthOptions = _getMonths().map((m) => "${m.monthName} ${m.year}").toList();
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.graphMode == 0 ? monthOptions : yearOptions;

    if (widget.controller.selected < 0) {
      widget.controller.setSelectedQuietly(
        options.length + widget.controller.selected,
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
      width: 150.0,

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options[widget.controller.selected],
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
              widget.controller.selected = options.indexOf(value!);
            });
          },
        ),
      ),
    );
  }

  List<int> _getYears() {
    widget.timestamps.sort();

    final years =
        widget.timestamps
            .map((t) => DateTime.fromMillisecondsSinceEpoch(t).year)
            .toSet()
            .toList();
    years.sort();

    return years;
  }

  List<MonthYear> _getMonths() {
    widget.timestamps.sort();

    final dateTimes =
        widget.timestamps
            .map((t) => DateTime.fromMillisecondsSinceEpoch(t))
            .toList();

    final monthYears =
        dateTimes.map((dt) => MonthYear(dt.month, dt.year)).toSet().toList();

    return monthYears;
  }
}

class MonthYear {
  final int month;
  final int year;
  const MonthYear(this.month, this.year);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthYear &&
          runtimeType == other.runtimeType &&
          month == other.month &&
          year == other.year;

  @override
  int get hashCode => "$month/$year".hashCode;

  String get monthName {
    final MONTHS = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return MONTHS[month - 1];
  }
}
