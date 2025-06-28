import 'package:flutter/material.dart';

class ResultsLabel extends StatelessWidget {
  const ResultsLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12.0),
        const Divider(height: 1.0),
        const SizedBox(height: 16.0),

        Text(
          "Loaded 10,000 messages",

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
}
