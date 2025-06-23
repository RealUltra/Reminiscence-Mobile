import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/graph/app_bar.dart';
import 'package:reminiscence/ui/pages/graph/body.dart';
import 'package:reminiscence/ui/pages/graph/chart_info.dart';
import 'package:reminiscence/ui/pages/graph/charts_notifier.dart';
import 'package:reminiscence/ui/pages/graph/dropdown_controller.dart';
import 'package:reminiscence/ui/pages/graph/switch_controller.dart';

class GraphPage extends StatefulWidget {
  final ReminiscenceData data;
  final ChatDto chat;

  const GraphPage({super.key, required this.data, required this.chat});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  bool isReady = false;

  final List<int> years = [];
  final List<int> timestamps = [];
  List<ChatDto> chats = [];

  final SwitchController separateParticipantsController = SwitchController();
  final DropdownController graphModeController = DropdownController(
    initialValue: 1,
  );
  final DropdownController monthController = DropdownController();
  final DropdownController yearController = DropdownController();
  final SwitchController allTimeController = SwitchController();
  final DropdownController chartTypeController = DropdownController();

  final chartsNotifier = ChartsNotifier();

  @override
  void initState() {
    super.initState();

    separateParticipantsController.addListener(() {
      if (chartsNotifier.charts.containsKey(widget.chat.id)) {
        final chart = chartsNotifier.charts[widget.chat.id];
        chart!.separateParticipants = separateParticipantsController.value;
        chartsNotifier.add(widget.chat.id, chart);
      }

      _updateWidgetSafely();
    });

    graphModeController.addListener(_updateWidgetSafely);
    monthController.addListener(_updateWidgetSafely);
    yearController.addListener(_updateWidgetSafely);
    allTimeController.addListener(_updateWidgetSafely);
    chartTypeController.addListener(_updateWidgetSafely);

    chartsNotifier.charts[widget.chat.id] = ChartInfo(chat: widget.chat);

    initData();
  }

  Future<void> initData() async {
    // Fetch chats
    chats.clear();
    chats = await widget.data.db.chatDao.getChatDtos();

    // Fetch timestamps & years
    final timestamps = await widget.data.db.messageDao.getMessageTimestamps(
      widget.chat.id,
    );

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

    yearController.setSelectedQuietly(years.length - 1);

    // Ready the widget
    isReady = true;
    _updateWidgetSafely();
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return Scaffold();
    }

    return MultiProvider(
      providers: [
        Provider<ReminiscenceData>.value(value: widget.data),
        Provider<ChatDto>.value(value: widget.chat),
        Provider<List<ChatDto>>.value(value: chats),
        ChangeNotifierProvider(create: (_) => chartsNotifier),
      ],
      child: Scaffold(
        appBar: MyAppBar(
          separateParticipantsController: separateParticipantsController,
          graphModeController: graphModeController,
          monthController: monthController,
          yearController: yearController,
          allTimeController: allTimeController,
          chartTypeController: chartTypeController,
          years: years,
        ),
        body: Body(
          separateParticipantsController: separateParticipantsController,
          graphModeController: graphModeController,
          monthController: monthController,
          yearController: yearController,
          allTimeController: allTimeController,
          chartTypeController: chartTypeController,
          years: years,
        ),
      ),
    );
  }

  void _updateWidgetSafely() {
    if (mounted) {
      setState(() {});
    }
  }
}
