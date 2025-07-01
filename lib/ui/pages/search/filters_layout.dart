import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/search/filter.dart';
import 'package:reminiscence/ui/pages/search/filter_badge.dart';
import 'package:reminiscence/ui/components/value_controller.dart';

class FiltersLayout extends StatelessWidget {
  final ValueController<Map<String, Filter>> controller;

  const FiltersLayout({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8.0,

        children: [
          const SizedBox(width: 4.0),

          ...getBadges(),

          const SizedBox(width: 4.0),
        ],
      ),
    );
  }

  List<FilterBadge> getBadges() {
    return controller.value.values
        .map(
          (f) => FilterBadge(
            f,
            onRemove: () {
              controller.value.remove(f.type.name);
              controller.notifyListeners();
            },
          ),
        )
        .toList();
  }
}
