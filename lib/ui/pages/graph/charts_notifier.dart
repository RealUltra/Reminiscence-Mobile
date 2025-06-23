import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/graph/chart_info.dart';

class ChartsNotifier extends ChangeNotifier {
  Map<int, ChartInfo> _charts = {};

  Map<int, ChartInfo> get charts => _charts;

  void add(int chatId, ChartInfo chart) {
    _charts[chatId] = chart;
    notifyListeners();
  }

  void remove(int chatId) {
    _charts.remove(chatId);
    notifyListeners();
  }

  void setCharts(Map<int, ChartInfo> charts) {
    _charts = charts;
    notifyListeners();
  }
}
