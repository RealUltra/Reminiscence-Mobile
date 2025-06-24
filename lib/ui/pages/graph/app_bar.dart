import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/ui/pages/graph/add_chat_dialog.dart';
import 'package:reminiscence/ui/pages/graph/chart_info.dart';
import 'package:reminiscence/ui/pages/graph/graph_settings.dart';
import 'package:reminiscence/ui/pages/graph/graph_settings_dialog.dart';
import 'package:reminiscence/ui/providers/session_data.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GraphSettings graphSettings;
  final List<int> years;
  final void Function(GraphSettings)? onSettingsUpdated;

  const MyAppBar({
    super.key,
    required this.graphSettings,
    required this.years,
    this.onSettingsUpdated,
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
    final sessionData = Provider.of<SessionData>(context, listen: false);
    final data = sessionData.data!;
    final chat = sessionData.chat!;
    final chats = sessionData.chats!;

    final newChartData = await showDialog<Map<int, ChartInfo>>(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext context) => AddChatDialog(
            data: data,
            chat: chat,
            chats: chats,
            chartData: Map.from(graphSettings.chartData),
          ),
    );

    if (newChartData != null && onSettingsUpdated != null) {
      graphSettings.chartData = newChartData;
      onSettingsUpdated!(graphSettings);
    }
  }

  Future<void> openGraphSettings(BuildContext context) async {
    final sessionData = Provider.of<SessionData>(context, listen: false);
    final chat = sessionData.chat!;

    final updatedSettings = await showDialog<GraphSettings>(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext context) => GraphSettingsDialog(
            initialSettings: graphSettings,
            chat: chat,
            years: years,
          ),
    );

    if (updatedSettings == null) {
      return;
    }

    if (onSettingsUpdated != null) {
      onSettingsUpdated!(updatedSettings);
    }
  }
}
