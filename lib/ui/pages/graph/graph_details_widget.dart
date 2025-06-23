import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/graph/dropdown_controller.dart';
import 'package:reminiscence/ui/pages/graph/switch_controller.dart';

class GraphDetailsWidget extends StatefulWidget {
  final int graphMode;
  final List<int> years;
  final DropdownController monthController;
  final DropdownController yearController;
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

    final children = <Widget>[];

    if (builtWidget != null) {
      children.add(
        Padding(padding: EdgeInsets.only(top: 8.0), child: builtWidget),
      );
    }

    children.add(_buildAllTimeSwitch());

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

      children: [
        _buildDropdown(widget.monthController, monthOptions),
        _buildDropdown(widget.yearController, yearOptions),
      ],
    );
  }

  Widget _buildMonthly() {
    return _buildDropdown(widget.yearController, yearOptions);
  }

  Widget _buildDropdown(DropdownController controller, List<String> options) {
    final disabled = widget.allTimeController.value;

    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 0.0, 4.0, 0.0),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),

      child: DropdownButton<int>(
        value: controller.selected,
        underline: Container(),

        items:
            options.map((text) {
              final index = options.indexOf(text);
              return DropdownMenuItem<int>(
                value: index,
                child: Text("$text   ", textAlign: TextAlign.center),
              );
            }).toList(),

        onChanged:
            disabled
                ? null
                : (int? value) {
                  if (value == null) return;

                  setState(() {
                    controller.selected = value;
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
