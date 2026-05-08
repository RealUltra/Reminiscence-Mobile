import 'package:flutter/material.dart';

class SwitchTab extends StatelessWidget {
  final String text;
  final bool active;
  final Function()? onTap;

  const SwitchTab({
    super.key,
    this.active = false,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        active
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest;

    final foregroundColor =
        active
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurface;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,

        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.0),

          decoration: BoxDecoration(
            color: backgroundColor,
            border: BoxBorder.all(color: foregroundColor),
          ),

          child: Center(
            child: Text(
              text,

              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
