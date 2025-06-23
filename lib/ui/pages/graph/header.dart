import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/ui/pages/graph/chart_badge.dart';
import 'package:reminiscence/ui/pages/graph/chart_info.dart';
import 'package:reminiscence/ui/pages/graph/charts_notifier.dart';
import 'package:reminiscence/ui/pages/graph/graph_data.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    final chartsNotifier = Provider.of<ChartsNotifier>(context);

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      padding: EdgeInsets.all(16.0),
      width: double.infinity,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: getBadges(chartsNotifier.charts.values.toList()),
      ),
    );
  }

  List<ChartBadge> getBadges(List<ChartInfo> charts) {
    final badges = <ChartBadge>[];

    final colors = GraphData.colors;

    for (final chart in charts) {
      if (chart.separateParticipants) {
        for (final participant in chart.chat.participants) {
          badges.add(
            ChartBadge(
              title: participant,
              color: colors[badges.length % colors.length],
              isChat: false,
              chatTitle: (charts.length == 1) ? null : chart.chat.title,
            ),
          );
        }
      } else {
        badges.add(
          ChartBadge(
            title: chart.chat.title,
            color: colors[badges.length % colors.length],
            isChat: true,
          ),
        );
      }
    }

    return badges;
  }
}
