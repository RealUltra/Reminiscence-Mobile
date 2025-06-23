import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/graph/chart_badge.dart';
import 'package:reminiscence/ui/pages/graph/chart_info.dart';

class BadgeLayout extends StatelessWidget {
  final Map<int, ChartInfo> charts;

  const BadgeLayout({super.key, required this.charts});

  @override
  Widget build(BuildContext context) {
    final badges = <ChartBadge>[];

    for (final chart in charts.values) {
      if (chart.separateParticipants) {
        for (final participant in chart.chat.participants) {
          badges.add(
            ChartBadge(
              title: participant,
              isChat: false,
              chatTitle: (charts.length == 1) ? null : chart.chat.title,
            ),
          );
        }
      } else {
        badges.add(ChartBadge(title: chart.chat.title, isChat: true));
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: Row(
        spacing: 8.0,

        children: [
          const SizedBox(width: 16.0),
          ...badges,
          const SizedBox(width: 16.0),
        ],
      ),
    );
  }
}
