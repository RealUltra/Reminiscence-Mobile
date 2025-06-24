import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/ui/pages/graph/app_bar.dart';
import 'package:reminiscence/ui/pages/graph/body.dart';
import 'package:reminiscence/ui/pages/graph/chart_info.dart';
import 'package:reminiscence/ui/pages/graph/data_point.dart';
import 'package:reminiscence/ui/pages/graph/graph_settings.dart';
import 'package:reminiscence/ui/providers/session_data.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  bool isReady = false;

  final List<int> years = [];
  late GraphSettings settings;

  @override
  void initState() {
    super.initState();

    DataPoint.shuffleColors();

    initData();
  }

  Future<void> initData() async {
    final sessionData = Provider.of<SessionData>(context, listen: false);
    final data = sessionData.data!;
    final chat = sessionData.chat!;

    // Fetch timestamps & years
    final timestamps = await data.db.messageDao.getMessageTimestamps(chat.id);

    years.clear();

    years.addAll(
      timestamps
          .map((t) => DateTime.fromMillisecondsSinceEpoch(t).year)
          .toSet()
          .toList(),
    );

    years.sort();

    // init settings
    settings = GraphSettings(
      separateParticipants: false,
      mode: 1,
      month: 12,
      year: years.last,
      allTime: false,
      chartType: 0,
      chartData: {chat.id: ChartInfo(chat: chat)},
    );

    // Ready the widget
    isReady = true;
    _updateWidgetSafely();
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return Scaffold();
    }

    return Scaffold(
      appBar: MyAppBar(
        graphSettings: settings,
        years: years,
        onSettingsUpdated:
            (newSettings) => setState(() => settings = newSettings),
      ),

      body: Body(graphSettings: settings, years: years),
    );
  }

  void _updateWidgetSafely() {
    if (mounted) {
      setState(() {});
    }
  }
}
