import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/graph/chart_badge.dart';
import 'package:reminiscence/ui/pages/graph/chart_info.dart';
import 'package:reminiscence/ui/pages/graph/data_point.dart';

class BadgesLayout extends StatelessWidget {
  final List<ChartInfo> charts;

  const BadgesLayout({super.key, required this.charts});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(spacing: 8.0, children: getBadges()),
    );
  }

  List<ChartBadge> getBadges() {
    final badges = <ChartBadge>[];

    for (final chart in charts) {
      if (chart.separateParticipants) {
        for (final participant in chart.chat.participants) {
          badges.add(
            ChartBadge(
              title: participant,
              color: DataPoint.getColor(badges.length),
              isChat: false,
              chatTitle: (charts.length == 1) ? null : chart.chat.title,
            ),
          );
        }
      } else {
        badges.add(
          ChartBadge(
            title: chart.chat.title,
            color: DataPoint.getColor(badges.length),
            isChat: true,
          ),
        );
      }
    }

    return badges;
  }
}
