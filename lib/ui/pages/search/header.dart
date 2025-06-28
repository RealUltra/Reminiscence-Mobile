import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/search/filters_layout.dart';
import 'package:reminiscence/ui/pages/search/results_label.dart';
import 'package:reminiscence/ui/pages/search/sort_selector.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      width: double.infinity,
      padding: EdgeInsets.only(top: 12.0, bottom: 12.0),

      child: Column(
        children: [
          FiltersLayout(),

          const SizedBox(height: 12.0),
          const Divider(height: 1.0),
          const SizedBox(height: 12.0),

          SortSelector(),
        ],
      ),
    );
  }
}
