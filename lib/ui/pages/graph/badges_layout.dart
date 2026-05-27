import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/graph/chart_badge.dart';
import 'package:reminiscence/ui/pages/graph/chart_info.dart';
import 'package:reminiscence/ui/pages/graph/graph_colors.dart';

class BadgesLayout extends StatelessWidget {
  final List<ChartInfo> charts;

  const BadgesLayout({super.key, required this.charts});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(spacing: 8.0, children: getBadges(context)),
    );
  }

  List<ChartBadge> getBadges(BuildContext context) {
    final badges = <ChartBadge>[];
    final brightness = Theme.of(context).brightness;

    for (final chart in charts) {
      if (chart.separateParticipants) {
        for (final participant in chart.chat.participants) {
          badges.add(
            ChartBadge(
              title: participant,
              color: GraphColors.getColor(brightness, badges.length),
              isChat: false,
              chatTitle: (charts.length == 1) ? null : chart.chat.title,
            ),
          );
        }
      } else {
        badges.add(
          ChartBadge(
            title: chart.chat.title,
            color: GraphColors.getColor(brightness, badges.length),
            isChat: true,
          ),
        );
      }
    }

    return badges;
  }
}
