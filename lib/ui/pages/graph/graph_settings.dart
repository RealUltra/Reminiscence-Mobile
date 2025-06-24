import 'package:reminiscence/ui/pages/graph/chart_info.dart';

class GraphSettings {
  bool separateParticipants;
  int mode;
  int month;
  int yearIndex;
  bool allTime;
  int chartType;
  Map<int, ChartInfo> chartData;

  GraphSettings({
    required this.separateParticipants,
    required this.mode,
    required this.month,
    required this.yearIndex,
    required this.allTime,
    required this.chartType,
    required this.chartData,
  });
}
