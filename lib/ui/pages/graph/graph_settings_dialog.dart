import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/graph/chart_type_widget.dart';
import 'package:reminiscence/ui/pages/graph/dropdown_controller.dart';
import 'package:reminiscence/ui/pages/graph/graph_details_widget.dart';
import 'package:reminiscence/ui/pages/graph/graph_mode_dropdown.dart';
import 'package:reminiscence/ui/pages/graph/graph_settings.dart';
import 'package:reminiscence/ui/pages/graph/separate_participants_switch.dart';
import 'package:reminiscence/ui/pages/graph/switch_controller.dart';

class GraphSettingsDialog extends StatefulWidget {
  final GraphSettings initialSettings;
  final List<int> years;

  const GraphSettingsDialog({
    super.key,
    required this.initialSettings,
    required this.years,
  });

  @override
  State<GraphSettingsDialog> createState() => _GraphSettingsDialogState();
}

class _GraphSettingsDialogState extends State<GraphSettingsDialog> {
  final SwitchController separateParticipantsController = SwitchController();
  final DropdownController graphModeController = DropdownController();
  final DropdownController monthController = DropdownController();
  final DropdownController yearController = DropdownController();
  final SwitchController allTimeController = SwitchController();
  final DropdownController chartTypeController = DropdownController();

  @override
  void initState() {
    super.initState();

    separateParticipantsController.value =
        widget.initialSettings.separateParticipants;
    graphModeController.selected = widget.initialSettings.mode;
    monthController.selected = widget.initialSettings.month;
    yearController.selected = widget.initialSettings.yearIndex;
    allTimeController.value = widget.initialSettings.allTime;
    chartTypeController.selected = widget.initialSettings.chartType;

    graphModeController.addListener(() {
      if (mounted) {
        setState(() {
          if (graphModeController.selected == 2) {
            allTimeController.value = true;
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
              controller: separateParticipantsController,
            ),

            const Divider(),
            const SizedBox(height: 8.0),

            GraphModeDropdown(controller: graphModeController),

            const SizedBox(height: 8.0),

            GraphDetailsWidget(
              graphMode: graphModeController.selected,
              years: widget.years,
              monthController: monthController,
              yearController: yearController,
              allTimeController: allTimeController,
            ),

            const Divider(),
            const SizedBox(height: 4.0),

            ChartTypeWidget(controller: chartTypeController),

            const Divider(),
            const SizedBox(height: 4.0),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  GraphSettings(
                    separateParticipants: separateParticipantsController.value,
                    mode: graphModeController.selected,
                    month: monthController.selected,
                    yearIndex: yearController.selected,
                    allTime: allTimeController.value,
                    chartType: chartTypeController.selected,
                  ),
                );
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
          ],
        ),
      ),
    );
  }
}
