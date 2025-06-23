import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/graph/graph_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Graph extends StatefulWidget {
  final List<List<GraphData>> dataSources;

  const Graph({super.key, required this.dataSources});

  @override
  State<Graph> createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      padding: EdgeInsets.all(12.0),

      child: SfCartesianChart(
        // Initialize category axis
        primaryXAxis: CategoryAxis(),
        tooltipBehavior: TooltipBehavior(enable: true),

        legend: Legend(isVisible: true, toggleSeriesVisibility: true),

        trackballBehavior: TrackballBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
        ),

        series:
            widget.dataSources
                .map<LineSeries<GraphData, String>>(
                  (dataSource) => LineSeries<GraphData, String>(
                    dataSource: dataSource,
                    xValueMapper: (GraphData data, _) => data.x,
                    yValueMapper: (GraphData data, _) => data.y,
                  ),
                )
                .toList(),
      ),
    );
  }
}
