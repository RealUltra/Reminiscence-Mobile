import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/graph/badges_layout.dart';
import 'package:reminiscence/ui/pages/graph/graph_settings.dart';

class Header extends StatefulWidget {
  final GraphSettings settings;
  final List<int> years;

  const Header({super.key, required this.settings, required this.years});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    final charts = widget.settings.chartData.values.toList();

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      padding: EdgeInsets.only(top: 16.0, bottom: 12.0),
      width: double.infinity,
      child: Column(
        children: [
          BadgesLayout(charts: charts),

          const SizedBox(height: 8.0),
          const Divider(),
          const SizedBox(height: 4.0),

          Text(
            "Viewing",
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Text(
            _getLabel(),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getLabel() {
    if (widget.settings.allTime) {
      String text = "All Time ";

      if (widget.settings.mode == 0) {
        text += "(Daily)";
      } else if (widget.settings.mode == 1) {
        text += "(Monthly)";
      } else {
        text += "(Yearly)";
      }

      return text;
    }

    final monthNames = [
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

    final monthName = monthNames[widget.settings.month];
    final year = widget.years[widget.settings.yearIndex];

    if (widget.settings.mode == 0) {
      return "$monthName $year";
    } else if (widget.settings.mode == 1) {
      return "$year";
    }

    return "Yearly";
  }
}
