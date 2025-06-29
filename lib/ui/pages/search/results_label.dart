import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/chats_list/utils.dart';

class ResultsLabel extends StatelessWidget {
  final bool isSearching;
  final int numResults;

  const ResultsLabel({
    super.key,
    required this.isSearching,
    required this.numResults,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12.0),
        const Divider(height: 1.0),
        const SizedBox(height: 16.0),

        Text(
          getText(),

          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),

          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4.0),
      ],
    );
  }

  String getText() {
    if (isSearching) {
      return "Searching...";
    }
    return "Loaded ${formatNumber(numResults)} messages";
  }
}
