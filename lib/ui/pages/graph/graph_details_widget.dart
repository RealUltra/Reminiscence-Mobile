import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';
import 'package:reminiscence/ui/components/switch_controller.dart';

class GraphDetailsWidget extends StatefulWidget {
  final int graphMode;
  final List<int> years;
  final SelectionController monthController;
  final SelectionController yearController;
  final SwitchController allTimeController;

  const GraphDetailsWidget({
    super.key,
    required this.graphMode,
    required this.years,
    required this.monthController,
    required this.yearController,
    required this.allTimeController,
  });

  @override
  State<GraphDetailsWidget> createState() => _GraphDetailsWidgetState();
}

class _GraphDetailsWidgetState extends State<GraphDetailsWidget> {
  List<String> yearOptions = [];
  List<String> monthOptions = [];

  @override
  void initState() {
    super.initState();

    yearOptions = widget.years.map((y) => y.toString()).toList();

    monthOptions = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
  }

  @override
  Widget build(BuildContext context) {
    Widget? builtWidget;

    if (widget.graphMode == 0) {
      builtWidget = _buildDaily();
    } else if (widget.graphMode == 1) {
      builtWidget = _buildMonthly();
    } else {
      builtWidget = null;
    }

    final children = <Widget>[_buildAllTimeSwitch()];

    if (builtWidget != null) {
      children.insert(
        0,
        Padding(padding: EdgeInsets.only(top: 8.0), child: builtWidget),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8.0,
      children: children,
    );
  }

  Widget _buildDaily() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8.0,

      children: [_buildMonthDropdown(), _buildYearDropdown()],
    );
  }

  Widget _buildMonthly() {
    return _buildYearDropdown();
  }

  Widget _buildYearDropdown() {
    final disabled = widget.allTimeController.value;

    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 0.0, 4.0, 0.0),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),

      child: DropdownButton<int>(
        value: widget.yearController.selected,
        underline: Container(),

        items:
            widget.years.map((text) {
              return DropdownMenuItem<int>(
                value: text.toInt(),
                child: Text("$text   ", textAlign: TextAlign.center),
              );
            }).toList(),

        onChanged:
            disabled
                ? null
                : (int? value) {
                  if (value == null) return;

                  setState(() {
                    widget.yearController.selected = value;
                  });
                },
      ),
    );
  }

  Widget _buildMonthDropdown() {
    final disabled = widget.allTimeController.value;

    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 0.0, 4.0, 0.0),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),

      child: DropdownButton<int>(
        value: widget.monthController.selected,
        underline: Container(),

        items:
            monthOptions.map((text) {
              final value = monthOptions.indexOf(text) + 1;

              return DropdownMenuItem<int>(
                value: value,
                child: Text("$text   ", textAlign: TextAlign.center),
              );
            }).toList(),

        onChanged:
            disabled
                ? null
                : (int? value) {
                  if (value == null) return;

                  setState(() {
                    widget.monthController.selected = value;
                  });
                },
      ),
    );
  }

  Widget _buildAllTimeSwitch() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8.0,

      children: [
        Text(
          "All Time:",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),

        Switch(
          value: widget.allTimeController.value,
          onChanged: (bool value) {
            if (widget.graphMode != 2) {
              setState(() {
                widget.allTimeController.value = value;
              });
            }
          },
        ),
      ],
    );
  }
}
