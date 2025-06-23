import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/ui/pages/graph/chart_info.dart';
import 'package:reminiscence/ui/pages/graph/charts_notifier.dart';
import 'package:reminiscence/ui/pages/graph/graph_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Graph extends StatefulWidget {
  final int mode;
  final int month;
  final int year;
  final bool allTime;
  final int chartType;

  const Graph({
    super.key,
    required this.mode,
    required this.month,
    required this.year,
    required this.allTime,
    required this.chartType,
  });

  @override
  State<Graph> createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  Future<List<GraphData>> loadData(
    ChartInfo chart, {
    String? participant,
  }) async {
    final Map<String, int> counter = {};
    final Map<int, String> timestampToLabel = {};

    final data = Provider.of<ReminiscenceData>(context, listen: false);

    final timestamps = await data.db.messageDao.getMessageTimestamps(
      chart.chat.id,
      senderName: participant,
    );
    timestamps.sort();

    for (final timestamp in timestamps) {
      final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final label = _getLabel(dt);

      bool isTargetDate = true;

      if (widget.mode == 0) {
        isTargetDate = (dt.month == widget.month) && (dt.year == widget.year);
      } else if (widget.mode == 1) {
        isTargetDate = dt.year == widget.year;
      }

      if (widget.allTime || isTargetDate) {
        if (!counter.containsKey(label)) {
          counter[label] = 0;
          timestampToLabel[timestamp] = label;
        }

        counter[label] = counter[label]! + 1;
      }
    }

    DateTime minDate = DateTime.fromMillisecondsSinceEpoch(timestamps[0]);
    DateTime maxDate = DateTime.fromMillisecondsSinceEpoch(
      timestamps[timestamps.length - 1],
    );

    for (int i = 0; i < maxDate.difference(minDate).inDays; i++) {
      final dt = minDate.add(Duration(days: i));
      final label = _getLabel(dt);

      if (!counter.containsKey(label)) {
        counter[label] = 0;
      }
    }

    final labelTimestamps = timestampToLabel.keys.toList();
    labelTimestamps.sort();

    List<GraphData> dataSource = [];

    for (final timestamp in labelTimestamps) {
      final label = timestampToLabel[timestamp]!;
      final count = counter[label]!;
      debugPrint(label);
      dataSource.add(GraphData(label, count));
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

  String _getLabel(DateTime dt) {
    if (widget.mode == 0) {
      return _getDayLabel(dt);
    } else if (widget.mode == 1) {
      return _getMonthLabel(dt);
    } else {
      return dt.year.toString();
    }
  }

  String _getDayLabel(DateTime dt) {
    if (widget.allTime) {
      return DateFormat('dd/MM/yyyy').format(dt);
    } else {
      return DateFormat('dd').format(dt);
    }
  }

  String _getMonthLabel(DateTime dt) {
    if (widget.allTime) {
      return DateFormat('MM/yyyy').format(dt);
    } else {
      return DateFormat('MM').format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chartsNotifier = Provider.of<ChartsNotifier>(context);

    return FutureBuilder(
      future: getDataSources(chartsNotifier.charts.values.toList()),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text("Error");
        } else if (!snapshot.hasData) {
          return Container();
        }

        final dataSources = snapshot.data!;

        return RotatedBox(
          quarterTurns: 1,

          child: SfCartesianChart(
            palette: GraphData.colors,
            margin: EdgeInsets.zero,

            primaryXAxis: CategoryAxis(
              labelPlacement: LabelPlacement.onTicks,
              interval: 1,
              majorGridLines: const MajorGridLines(width: 0),
              labelIntersectAction: AxisLabelIntersectAction.rotate90,
              labelStyle: Theme.of(context).textTheme.labelSmall,
            ),

            trackballBehavior: TrackballBehavior(
              enable: true,
              activationMode: ActivationMode.singleTap,
            ),

            series:
                widget.chartType == 0
                    ? generateLineChart(dataSources)
                    : generateBarChart(dataSources),
          ),
        );
      },
    );
  }

  List<LineSeries<GraphData, String>> generateLineChart(
    List<List<GraphData>> dataSources,
  ) {
    return dataSources
        .map<LineSeries<GraphData, String>>(
          (dataSource) => LineSeries<GraphData, String>(
            dataSource: dataSource,
            xValueMapper: (GraphData data, _) => data.x,
            yValueMapper: (GraphData data, _) => data.y,
          ),
        )
        .toList();
  }

  List<BarSeries<GraphData, String>> generateBarChart(
    List<List<GraphData>> dataSources,
  ) {
    return dataSources
        .map<BarSeries<GraphData, String>>(
          (dataSource) => BarSeries<GraphData, String>(
            dataSource: dataSource,
            xValueMapper: (GraphData data, _) => data.x,
            yValueMapper: (GraphData data, _) => data.y,
          ),
        )
        .toList();
  }
}
