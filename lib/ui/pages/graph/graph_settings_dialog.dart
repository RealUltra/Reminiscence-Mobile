import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/graph/chart_type_widget.dart';
import 'package:reminiscence/ui/pages/graph/dropdown_controller.dart';
import 'package:reminiscence/ui/pages/graph/graph_details_widget.dart';
import 'package:reminiscence/ui/pages/graph/graph_mode_dropdown.dart';
import 'package:reminiscence/ui/pages/graph/separate_participants_switch.dart';
import 'package:reminiscence/ui/pages/graph/switch_controller.dart';

class GraphSettingsDialog extends StatefulWidget {
  final SwitchController separateParticipantsController;
  final DropdownController graphModeController;
  final DropdownController monthController;
  final DropdownController yearController;
  final SwitchController allTimeController;
  final DropdownController chartTypeController;
  final List<int> years;

  const GraphSettingsDialog({
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
  State<GraphSettingsDialog> createState() => _GraphSettingsDialogState();
}

class _GraphSettingsDialogState extends State<GraphSettingsDialog> {
  @override
  void initState() {
    super.initState();

    widget.graphModeController.addListener(() {
      if (mounted) {
        setState(() {
          if (widget.graphModeController.selected == 2) {
            widget.allTimeController.value = true;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.0),

      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            SeparateParticipantsSwitch(
              controller: widget.separateParticipantsController,
            ),

            const Divider(),
            const SizedBox(height: 8.0),

            GraphModeDropdown(controller: widget.graphModeController),

            const SizedBox(height: 8.0),

            GraphDetailsWidget(
              graphMode: widget.graphModeController.selected,
              years: widget.years,
              monthController: widget.monthController,
              yearController: widget.yearController,
              allTimeController: widget.allTimeController,
            ),

            const Divider(),
            const SizedBox(height: 4.0),

            ChartTypeWidget(controller: widget.chartTypeController),
          ],
        ),
      ),
    );
  }
}
