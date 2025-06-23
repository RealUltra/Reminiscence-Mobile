import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/graph/Graph.dart';
import 'package:reminiscence/ui/pages/graph/dropdown_controller.dart';
import 'package:reminiscence/ui/pages/graph/header.dart';
import 'package:reminiscence/ui/pages/graph/switch_controller.dart';

class Body extends StatefulWidget {
  final SwitchController separateParticipantsController;
  final DropdownController graphModeController;
  final DropdownController monthController;
  final DropdownController yearController;
  final SwitchController allTimeController;
  final DropdownController chartTypeController;
  final List<int> years;

  const Body({
    super.key,
    required this.separateParticipantsController,
    required this.graphModeController,
    required this.monthController,
    required this.yearController,
    required this.allTimeController,
    required this.chartTypeController,
    required this.years,
  });

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,

        child: Column(
          children: [
            Header(),

            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(12.0, 16.0, 24.0, 16.0),

                child: Graph(
                  mode: widget.graphModeController.selected,
                  month: widget.monthController.selected + 1,
                  year: widget.years[widget.yearController.selected],
                  allTime: widget.allTimeController.value,
                  chartType: widget.chartTypeController.selected,
                ),
              ),
            ),

            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
