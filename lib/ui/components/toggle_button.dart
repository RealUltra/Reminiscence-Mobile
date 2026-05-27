import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';

class ToggleButton extends StatefulWidget {
  final List<ToggleButtonValue> values;
  final SelectionController<int> controller;
  final BoxDecoration decoration;

  const ToggleButton({
    super.key,
    required this.values,
    required this.controller,
    this.decoration = const BoxDecoration(),
  });

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  @override
  Widget build(BuildContext context) {
    final currentValue = widget.values[widget.controller.selected];
    final icon = currentValue.icon;
    final title = currentValue.title;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fillWidth = constraints.hasBoundedWidth;

        return InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            final nextIndex =
                (widget.controller.selected + 1) % widget.values.length;
            widget.controller.selected = nextIndex;
          },
          child: Container(
            width: fillWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: widget.decoration,
            child: Row(
              mainAxisSize: fillWidth ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (fillWidth)
                  Expanded(child: _buildTitle(context, title))
                else
                  _buildTitle(context, title),
                const SizedBox(width: 8.0),
                Icon(
                  icon,
                  size: 18.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle(BuildContext context, String title) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class ToggleButtonValue {
  final IconData icon;
  final String title;

  ToggleButtonValue({required this.icon, required this.title});
}
