import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/switch_controller.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController textController;
  final SwitchController switchController;
  final String labelText;

  const PasswordField({
    super.key,
    required this.textController,
    required this.switchController,
    this.labelText = 'Password',
  });

  @override
  Widget build(BuildContext context) {
    final showPassword = switchController.value;

    return TextField(
      controller: textController,
      maxLines: 1,
      obscureText: !showPassword,

      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),

        labelText: labelText,

        suffixIcon: IconButton(
          icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),

          onPressed: () {
            switchController.value = !switchController.value;
          },
        ),
      ),
    );
  }
}
