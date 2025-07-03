import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/data_loader/password_entry/bullet_point.dart';

class EnterPasswordTitle extends StatelessWidget {
  const EnterPasswordTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Enter Password",
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 24),

        BulletPoint("This .rem file is password-protected."),

        BulletPoint(
          "If you do not remember your password, you must rebuild it from the .zip file.",
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
