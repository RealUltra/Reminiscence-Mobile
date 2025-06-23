import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/ui/pages/graph/badge_layout.dart';
import 'package:reminiscence/ui/pages/graph/chart_type_widget.dart';
import 'package:reminiscence/ui/pages/graph/charts_notifier.dart';
import 'package:reminiscence/ui/pages/graph/dropdown_controller.dart';
import 'package:reminiscence/ui/pages/graph/graph_details_widget.dart';
import 'package:reminiscence/ui/pages/graph/graph_mode_dropdown.dart';
import 'package:reminiscence/ui/pages/graph/separate_participants_switch.dart';
import 'package:reminiscence/ui/pages/graph/switch_controller.dart';

class Header extends StatefulWidget {
  final List<int> years;

  final SwitchController separateParticipantsController;
  final DropdownController graphModeController;
  final DropdownController monthController;
  final DropdownController yearController;
  final SwitchController allTimeController;
  final DropdownController chartTypeController;

  const Header({
    super.key,
    required this.years,
    required this.separateParticipantsController,
    required this.graphModeController,
    required this.monthController,
    required this.yearController,
    required this.allTimeController,
    required this.chartTypeController,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    final chartsNotifier = Provider.of<ChartsNotifier>(context);

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      padding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 12.0),
      width: double.infinity,

      child: Column(
        children: [
          BadgeLayout(charts: chartsNotifier.charts),

          const SizedBox(height: 8.0),
          const Divider(),

          SeparateParticipantsSwitch(
            controller: widget.separateParticipantsController,
          ),

          const Divider(),
          const SizedBox(height: 8.0),

          GraphModeDropdown(controller: widget.graphModeController),

          const SizedBox(height: 8.0),

          GraphDetailsWidget(
            graphMode: widget.graphModeController.selected,
            years: widget.years,
            monthController: widget.monthController,
            yearController: widget.yearController,
            allTimeController: widget.allTimeController,
          ),

          const Divider(),
          const SizedBox(height: 4.0),

          ChartTypeWidget(controller: widget.chartTypeController),
        ],
      ),
    );
  }
}
