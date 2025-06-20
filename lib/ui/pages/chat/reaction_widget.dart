import 'package:flutter/material.dart';

class ReactionWidget extends StatelessWidget {
  final String emoji;
  final int numReactions;
  final bool highlight;

  const ReactionWidget(
    this.emoji, {
    super.key,
    this.numReactions = 1,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        highlight
            ? Theme.of(context).colorScheme.primaryContainer.withAlpha(200)
            : Theme.of(context).colorScheme.surfaceContainerLow;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      margin: EdgeInsets.only(top: 4.0),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: color,
      ),

      child: Text(
        "$emoji  $numReactions",
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
