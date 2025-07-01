import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/graph/chart_info.dart';

class DoneButton extends StatelessWidget {
  final Map<int, ChartInfo> chartData;

  const DoneButton({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),

      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context, chartData);
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 8,
        ),

        child: SizedBox(
          width: double.infinity,
          child: Text(
            "Done",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
