import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/graph/Graph.dart';
import 'package:reminiscence/ui/pages/graph/chart_info.dart';
import 'package:reminiscence/ui/pages/graph/charts_notifier.dart';
import 'package:reminiscence/ui/pages/graph/dropdown_controller.dart';
import 'package:reminiscence/ui/pages/graph/graph_data.dart';
import 'package:reminiscence/ui/pages/graph/header.dart';
import 'package:reminiscence/ui/pages/graph/switch_controller.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool isReady = false;

  final SwitchController separateParticipantsController = SwitchController();
  final DropdownController graphModeController = DropdownController(
    initialValue: 1,
  );
  final DropdownController monthController = DropdownController();
  final DropdownController yearController = DropdownController();
  final SwitchController allTimeController = SwitchController();
  final DropdownController chartTypeController = DropdownController();

  final List<int> years = [];
  final List<int> timestamps = [];

  @override
  void initState() {
    super.initState();

    separateParticipantsController.addListener(() {
      final chat = Provider.of<ChatDto>(context, listen: false);
      final chartsNotifier = Provider.of<ChartsNotifier>(
        context,
        listen: false,
      );

      if (chartsNotifier.charts.containsKey(chat.id)) {
        final chart = chartsNotifier.charts[chat.id];
        chart!.separateParticipants = separateParticipantsController.value;
        chartsNotifier.add(chat.id, chart);
      }

      _updateWidgetSafely();
    });

    graphModeController.addListener(_updateWidgetSafely);
    monthController.addListener(_updateWidgetSafely);
    yearController.addListener(_updateWidgetSafely);
    allTimeController.addListener(_updateWidgetSafely);
    chartTypeController.addListener(_updateWidgetSafely);

    final chartsNotifier = Provider.of<ChartsNotifier>(context, listen: false);
    final chat = Provider.of<ChatDto>(context, listen: false);
    chartsNotifier.charts[chat.id] = ChartInfo(chat: chat);

    fetchTimestamps();
  }

  Future<void> fetchTimestamps() async {
    final data = Provider.of<ReminiscenceData>(context, listen: false);
    final chat = Provider.of<ChatDto>(context, listen: false);

    final timestamps = await data.db.messageDao.getMessageTimestamps(chat.id);

    this.timestamps.clear();
    this.timestamps.addAll(timestamps);

    years.clear();
    years.addAll(
      timestamps
          .map((t) => DateTime.fromMillisecondsSinceEpoch(t).year)
          .toSet()
          .toList(),
    );
    years.sort();

    if (mounted) {
      setState(() {
        isReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return Container();
    }

    final chartsNotifier = Provider.of<ChartsNotifier>(context);

    return SafeArea(
      child: Column(
        children: [
          Header(
            years: years,
            separateParticipantsController: separateParticipantsController,
            graphModeController: graphModeController,
            monthController: monthController,
            yearController: yearController,
            allTimeController: allTimeController,
            chartTypeController: chartTypeController,
          ),
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: FutureBuilder<List<List<GraphData>>>(
              future: getDataSources(chartsNotifier.charts.values.toList()),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<List<GraphData>>> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasError) {
                  return Container();
                } else if (!snapshot.hasData) {
                  return Container();
                }

                return Graph(dataSources: snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _updateWidgetSafely() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<List<GraphData>> loadData(
    ChartInfo chart, {
    String? participant,
  }) async {
    List<GraphData> dataSource = [];

    final Map<String, int> counter = {};

    final mode = graphModeController.selected;
    final month = monthController.selected + 1;
    final year = years[yearController.selected];

    for (final timestamp in timestamps.reversed) {
      final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);

      String label;
      bool isTargetDate;
      bool isTargetParticipant;

      if (mode == 0) {
        label = _getDayLabel(dt);
        isTargetDate = (dt.month == month) && (dt.year == year);
      } else if (mode == 1) {
        label = _getMonthLabel(dt);
        isTargetDate = dt.year == year;
      } else {
        label = dt.year.toString();
        isTargetDate = true;
      }

      if (participant != null) {
        isTargetParticipant = participant == true;
      } else {
        isTargetParticipant = true;
      }

      if ((allTimeController.value || isTargetDate) && isTargetParticipant) {
        counter[label] ??= 0;
        counter[label] = counter[label]! + 1;
      }
    }

    for (final entry in counter.entries) {
      dataSource.add(GraphData(entry.key, entry.value));
    }

    return dataSource;
  }

  Future<List<List<GraphData>>> getDataSources(List<ChartInfo> charts) async {
    List<List<GraphData>> dataSources = [];

    for (final chart in charts) {
      if (chart.separateParticipants) {
        for (final participant in chart.chat.participants) {
          dataSources.add(await loadData(chart, participant: participant));
        }
      } else {
        dataSources.add(await loadData(chart));
      }
    }

    return dataSources;
  }

  String _getDayLabel(DateTime dt) {
    if (allTimeController.value) {
      return DateFormat('dd/MM/yyyy').format(dt);
    } else {
      return DateFormat('dd').format(dt);
    }
  }

  String _getMonthLabel(DateTime dt) {
    if (allTimeController.value) {
      return DateFormat('MM/yyyy').format(dt);
    } else {
      return DateFormat('MM').format(dt);
    }
  }
}
