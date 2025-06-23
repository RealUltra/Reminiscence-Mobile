import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/graph/add_chat_dialog.dart';
import 'package:reminiscence/ui/pages/graph/chart_info.dart';
import 'package:reminiscence/ui/pages/graph/charts_notifier.dart';
import 'package:reminiscence/ui/pages/graph/dropdown_controller.dart';
import 'package:reminiscence/ui/pages/graph/graph_settings_dialog.dart';
import 'package:reminiscence/ui/pages/graph/switch_controller.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SwitchController separateParticipantsController;
  final DropdownController graphModeController;
  final DropdownController monthController;
  final DropdownController yearController;
  final SwitchController allTimeController;
  final DropdownController chartTypeController;
  final List<int> years;

  const MyAppBar({
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
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      title: Text(
        "Graph View",
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      scrolledUnderElevation: 0.0,

      actions: [
        IconButton(icon: Icon(Icons.add), onPressed: () => addNewChat(context)),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => openGraphSettings(context),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  Future<void> addNewChat(BuildContext context) async {
    final data = Provider.of<ReminiscenceData>(context, listen: false);
    final chat = Provider.of<ChatDto>(context, listen: false);
    final chats = Provider.of<List<ChatDto>>(context, listen: false);
    final chartsNotifier = Provider.of<ChartsNotifier>(context, listen: false);

    final charts = await showDialog<Map<int, ChartInfo>>(
      context: context,
      builder:
          (BuildContext context) => AddChatDialog(
            data: data,
            chat: chat,
            chats: chats,
            charts: chartsNotifier.charts,
          ),
    );

    if (charts != null) {
      chartsNotifier.setCharts(charts);
    }
  }

  Future<void> openGraphSettings(BuildContext context) async {
    await showDialog<Map<int, ChartInfo>>(
      context: context,
      builder:
          (BuildContext context) => GraphSettingsDialog(
            separateParticipantsController: separateParticipantsController,
            graphModeController: graphModeController,
            monthController: monthController,
            yearController: yearController,
            allTimeController: allTimeController,
            chartTypeController: chartTypeController,
            years: years,
          ),
    );
  }
}
