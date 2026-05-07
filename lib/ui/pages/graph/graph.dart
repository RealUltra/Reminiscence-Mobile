import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/ui/pages/graph/data_point.dart';
import 'package:reminiscence/ui/pages/graph/graph_data_loader.dart';
import 'package:reminiscence/ui/pages/graph/graph_settings.dart';
import 'package:reminiscence/ui/providers/session_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Graph extends StatefulWidget {
  final GraphSettings settings;

  const Graph({super.key, required this.settings});

  @override
  State<Graph> createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  @override
  Widget build(BuildContext context) {
    final sessionData = Provider.of<SessionData>(context);
    final data = sessionData.data!;

    final dataLoader = GraphDataLoader(data: data, settings: widget.settings);

    return FutureBuilder<List<List<DataPoint>>>(
      future: dataLoader.getDataSources(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (!snapshot.hasData) {
          return Container();
        }

        final dataSources = snapshot.data!;

        int quarterTurns = 0;

        if (widget.settings.chartType == 1) {
          quarterTurns = -1;
        } else if (MediaQuery.orientationOf(context) == Orientation.portrait) {
          quarterTurns = 1;
        }

        return Container(
          margin: EdgeInsets.all(16.0),

          child: RotatedBox(
            quarterTurns: quarterTurns,

            child: SfCartesianChart(
              palette: DataPoint.colors,
              margin: EdgeInsets.zero,

              primaryXAxis: CategoryAxis(
                labelPlacement: LabelPlacement.betweenTicks,
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
                  widget.settings.chartType == 0
                      ? generateLineChart(dataSources)
                      : generateBarChart(dataSources),
            ),
          ),
        );
      },
    );
  }

  List<LineSeries<DataPoint, String>> generateLineChart(
    List<List<DataPoint>> dataSources,
  ) {
    return dataSources
        .map<LineSeries<DataPoint, String>>(
          (dataSource) => LineSeries<DataPoint, String>(
            dataSource: dataSource,
            xValueMapper: (DataPoint data, _) => data.x,
            yValueMapper: (DataPoint data, _) => data.y,
          ),
        )
        .toList();
  }

  List<BarSeries<DataPoint, String>> generateBarChart(
    List<List<DataPoint>> dataSources,
  ) {
    return dataSources
        .map<BarSeries<DataPoint, String>>(
          (dataSource) => BarSeries<DataPoint, String>(
            dataSource: dataSource,
            xValueMapper: (DataPoint data, _) => data.x,
            yValueMapper: (DataPoint data, _) => data.y,
          ),
        )
        .toList();
  }
}
