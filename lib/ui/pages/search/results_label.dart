import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/data_viewer/chats_list/utils.dart';

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
    return Text(
      getText(),

      style: Theme.of(context).textTheme.bodySmall!.copyWith(
        color: Theme.of(context).colorScheme.secondary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),

      textAlign: TextAlign.center,
    );
  }

  String getText() {
    if (isSearching) {
      return "Searching...";
    }
    return "${formatNumber(numResults)} messages";
  }
}
