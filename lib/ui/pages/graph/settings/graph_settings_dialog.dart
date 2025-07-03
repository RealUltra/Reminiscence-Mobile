import 'package:flutter/material.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/graph/chart_info.dart';
import 'package:reminiscence/ui/pages/graph/chart_type_widget.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';
import 'package:reminiscence/ui/pages/graph/graph_details_widget.dart';
import 'package:reminiscence/ui/pages/graph/graph_mode_selector.dart';
import 'package:reminiscence/ui/pages/graph/graph_settings.dart';
import 'package:reminiscence/ui/pages/graph/separate_participants_switch.dart';
import 'package:reminiscence/ui/components/switch_controller.dart';

class GraphSettingsDialog extends StatefulWidget {
  final GraphSettings initialSettings;
  final ChatDto chat;
  final List<int> years;

  const GraphSettingsDialog({
    super.key,
    required this.initialSettings,
    required this.chat,
    required this.years,
  });

  @override
  State<GraphSettingsDialog> createState() => _GraphSettingsDialogState();
}

class _GraphSettingsDialogState extends State<GraphSettingsDialog> {
  final SwitchController separateParticipantsController = SwitchController();
  final SelectionController<int> graphModeController = SelectionController(1);
  final SelectionController<int> monthController = SelectionController(12);
  late final SelectionController<int> yearController;
  final SwitchController allTimeController = SwitchController();
  final SelectionController<int> chartTypeController = SelectionController(0);

  late final Map<int, ChartInfo> chartData;

  @override
  void initState() {
    super.initState();

    chartData = Map.from(widget.initialSettings.chartData);
    yearController = SelectionController(widget.years.last);

    separateParticipantsController.value =
        widget.initialSettings.separateParticipants;
    graphModeController.selected = widget.initialSettings.mode;
    monthController.selected = widget.initialSettings.month;
    yearController.selected = widget.initialSettings.year;
    allTimeController.value = widget.initialSettings.allTime;
    chartTypeController.selected = widget.initialSettings.chartType;

    graphModeController.addListener(onModeChanged);
    separateParticipantsController.addListener(onParticipantsSeparated);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.0),

      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            SeparateParticipantsSwitch(
              controller: separateParticipantsController,
            ),

            const Divider(),
            const SizedBox(height: 8.0),

            GraphModeSelector(controller: graphModeController),

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
              onPressed: close,

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

  void close() {
    Navigator.pop(
      context,
      GraphSettings(
        separateParticipants: separateParticipantsController.value,
        mode: graphModeController.selected,
        month: monthController.selected,
        year: yearController.selected,
        allTime: allTimeController.value,
        chartType: chartTypeController.selected,
        chartData: chartData,
      ),
    );
  }

  void onModeChanged() {
    if (mounted) {
      setState(() {
        if (graphModeController.selected == 2) {
          allTimeController.value = true;
        }
      });
    }
  }

  void onParticipantsSeparated() {
    if (mounted) {
      setState(() {
        chartData[widget.chat.id]?.separateParticipants =
            separateParticipantsController.value;
      });
    }
  }
}
