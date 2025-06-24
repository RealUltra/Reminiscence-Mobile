import 'dart:math';

import 'package:intl/intl.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/graph/data_point.dart';
import 'package:reminiscence/ui/pages/graph/graph_settings.dart';

class GraphDataLoader {
  final ReminiscenceData data;
  final GraphSettings settings;

  final _allMessageTimestamps = <int>[];
  final _messageCounts = <int>[];

  GraphDataLoader({required this.data, required this.settings});

  Future<List<List<DataPoint>>> getDataSources() async {
    List<List<DataPoint>> dataSources = [];

    await prepareTimestamps();

    for (final graphInfo in iterGraphs()) {
      dataSources.add(
        await getDataSource(
          chat: graphInfo["chat"],
          messageTimestamps: getMessageTimestamps(graphInfo["index"]),
          participant: graphInfo["participant"],
        ),
      );
    }

    return dataSources;
  }

  Future<List<DataPoint>> getDataSource({
    required ChatDto chat,
    required List<int> messageTimestamps,
    String? participant,
  }) async {
    // label : count
    // Keeps track of how many messages are there for each label.
    final counter = <String, int>{};

    // timestamp : label
    // Each label will have only one corresponding timestamp. The timestamps will be sorted to sort the labels later.
    final timestampToLabel = <int, String>{};

    // Counting the number of relevant messages.
    for (final timestamp in messageTimestamps) {
      final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final label = _getLabel(dt);

      if (_isTargetDate(dt)) {
        if (!counter.containsKey(label)) {
          counter[label] = 0;
          timestampToLabel[timestamp] = label;
        }

        counter[label] = counter[label]! + 1;
      }
    }

    // Padding the labels
    for (final entry in getLabels().entries) {
      final label = entry.key;
      final timestamp = entry.value;

      if (!counter.containsKey(label)) {
        counter[label] = 0;
        timestampToLabel[timestamp] = label;
      }
    }

    // Sorting the label timestamps to traverse the labels in order.
    final labelTimestamps = timestampToLabel.keys.toList();
    labelTimestamps.sort();

    List<DataPoint> dataSource = [];

    // Traversing the labels through the sorted timestamps.
    // Adding each data point to the list.
    for (final timestamp in labelTimestamps) {
      final label = timestampToLabel[timestamp]!;
      final count = counter[label]!;
      dataSource.add(DataPoint(label, count));
    }

    return dataSource;
  }

  Future<void> prepareTimestamps() async {
    _allMessageTimestamps.clear();
    _messageCounts.clear();

    for (final graphInfo in iterGraphs()) {
      final chat = graphInfo["chat"] as ChatDto;
      final senderName = graphInfo["participant"];
      final timestamps = await data.db.messageDao.getMessageTimestamps(
        chat.id,
        senderName: senderName,
      );

      _allMessageTimestamps.addAll(timestamps);
      _messageCounts.add(timestamps.length);
    }
  }

  Map<String, int> getLabels() {
    /*
    Daily Mode:
      - 01 to month end

    Monthly Mode:
      - Jan to Dec
    
    Yearly Mode:
      - {years}

    All Time:
      - Smallest of all the timestamps combined, largest of all the timestamps combined
    */

    final labels = <String, int>{}; // label : timestamp

    // All time
    if (settings.allTime) {
      final minimum = DateTime.fromMillisecondsSinceEpoch(
        _allMessageTimestamps.reduce(min),
      );

      final maximum = DateTime.fromMillisecondsSinceEpoch(
        _allMessageTimestamps.reduce(max),
      );

      final difference = maximum.difference(minimum).inDays;

      for (int i = 0; i < difference; i++) {
        final dt = minimum.add(Duration(days: i));
        final label = _getLabel(dt);

        if (!labels.containsKey(label)) {
          labels[label] = dt.millisecondsSinceEpoch;
        }
      }
    }
    // Daily mode
    else if (settings.mode == 0) {
      for (int i = 0; i < _getDaysInMonth(settings.month, settings.year); i++) {
        final day = i + 1;
        final dt = DateTime(settings.year, settings.month, day);
        labels[_getDayLabel(dt)] = dt.millisecondsSinceEpoch;
      }
    }
    // Monthly mode
    else if (settings.mode == 1) {
      for (int i = 0; i < 12; i++) {
        final month = i + 1;
        final dt = DateTime(settings.year, month, 1);
        labels[_getMonthLabel(dt)] = dt.millisecondsSinceEpoch;
      }
    }
    // Yearly mode
    else {
      final minYear =
          DateTime.fromMillisecondsSinceEpoch(
            _allMessageTimestamps.reduce(min),
          ).year;

      final maxYear =
          DateTime.fromMillisecondsSinceEpoch(
            _allMessageTimestamps.reduce(max),
          ).year;

      for (int year = minYear; year < maxYear; year++) {
        final dt = DateTime(year, 1, 1);
        labels[year.toString()] = dt.millisecondsSinceEpoch;
      }
    }

    return labels;
  }

  List<int> getMessageTimestamps(int graphIndex) {
    final lengths = _messageCounts.sublist(0, graphIndex);

    final index = graphIndex == 0 ? 0 : lengths.reduce((a, b) => a + b);
    final messageCount = _messageCounts[graphIndex];

    return _allMessageTimestamps.sublist(index, index + messageCount);
  }

  List<Map<String, dynamic>> iterGraphs() {
    final charts = settings.chartData.values;

    final graphs = <Map<String, dynamic>>[];

    for (final chart in charts) {
      if (chart.separateParticipants) {
        for (final participant in chart.chat.participants) {
          graphs.add({
            "index": graphs.length,
            "chat": chart.chat,
            "participant": participant,
          });
        }
      } else {
        graphs.add({"index": graphs.length, "chat": chart.chat});
      }
    }

    return graphs;
  }

  bool _isTargetDate(DateTime dt) {
    if (settings.allTime) {
      return true;
    }

    if (settings.mode == 0) {
      return (dt.month == settings.month) && (dt.year == settings.year);
    } else if (settings.mode == 1) {
      return dt.year == settings.year;
    }

    return true;
  }

  String _getLabel(DateTime dt) {
    if (settings.mode == 0) {
      return _getDayLabel(dt);
    } else if (settings.mode == 1) {
      return _getMonthLabel(dt);
    } else {
      return dt.year.toString();
    }
  }

  String _getDayLabel(DateTime dt) {
    if (settings.allTime) {
      return DateFormat('dd/MM/yyyy').format(dt);
    } else {
      return dt.day.toString();
    }
  }

  String _getMonthLabel(DateTime dt) {
    if (settings.allTime) {
      return "${_getMonthName(dt.month)} ${dt.year}";
    } else {
      return _getMonthName(dt.month);
    }
  }

  int _getDaysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  String _getMonthName(int month) {
    final monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    return monthNames[month - 1];
  }
}
