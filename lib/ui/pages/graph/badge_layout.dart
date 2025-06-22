import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/graph/chart_badge.dart';

class BadgeLayout extends StatelessWidget {
  const BadgeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,

      children: [
        ChartBadge(
          title: "Mirza Rameez Ahmed Baig",
          isChat: false,
          chatTitle: "other person",
        ),
        ChartBadge(
          title: "other person",
          isChat: false,
          chatTitle: "other person",
        ),
        ChartBadge(
          title: "other person",
          isChat: false,
          chatTitle: "other person",
        ),
      ],
    );
  }
}
