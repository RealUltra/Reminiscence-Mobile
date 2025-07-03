import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/switch_controller.dart';

class SeparateParticipantsSwitch extends StatefulWidget {
  final SwitchController controller;

  const SeparateParticipantsSwitch({super.key, required this.controller});

  @override
  State<SeparateParticipantsSwitch> createState() =>
      _SeparateParticipantsSwitchState();
}

class _SeparateParticipantsSwitchState
    extends State<SeparateParticipantsSwitch> {
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8.0,
      mainAxisSize: MainAxisSize.min,

      children: [
        Text(
          "Separate Participants:",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Switch(
          value: widget.controller.value,
          onChanged: (bool value) {
            setState(() {
              widget.controller.value = value;
            });
          },
        ),
      ],
    );
  }
}
