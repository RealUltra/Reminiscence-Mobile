import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/data_loader/password_entry/bullet_point.dart';

class CreatePasswordTitle extends StatelessWidget {
  const CreatePasswordTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Create Password",
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 24),

        Text(
          "You're loading your raw Instagram data. To protect your data, please enter a password to encrypt it into a secure .rem file.",
        ),

        const SizedBox(height: 8),

        BulletPoint(
          "If you have already created a `.rem` file, please load it instead of the `.zip` file.",
        ),

        const SizedBox(height: 8),

        BulletPoint(
          "For added security, delete the `.zip` file after conversion.",
        ),

        const SizedBox(height: 8),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.error,
              size: 20.0,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                "Encryption is currently not recommended. It is very slow, and your data always stays on your device anyway.",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
