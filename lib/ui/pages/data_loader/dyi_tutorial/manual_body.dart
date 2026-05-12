import 'package:flutter/material.dart';
import 'package:reminiscence/features/notifications/reminder_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

class ManualBody extends StatelessWidget {
  const ManualBody({super.key});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse("instagram://settings");

    return Column(
      spacing: 16.0,
      children: [
        GestureDetector(
          onTap: () => _openDataRequestLink(uri),
          child: Text(
            "Click here to open settings in the Instagram app, then follow these instructions.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
              decorationColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),

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
                "Instagram can take up to 24 hours to provide your data.",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),

        _bordered(
          context,
          Image.asset("assets/tutorial_p1.jpg", fit: BoxFit.contain),
        ),
        _bordered(
          context,
          Image.asset("assets/tutorial_p2.jpg", fit: BoxFit.contain),
        ),
        _bordered(
          context,
          Image.asset("assets/tutorial_p3.jpg", fit: BoxFit.contain),
        ),
        _bordered(
          context,
          Image.asset("assets/tutorial_p4.jpg", fit: BoxFit.contain),
        ),
        _bordered(
          context,
          Image.asset("assets/tutorial_asset_1.png", fit: BoxFit.contain),
        ),
        _bordered(
          context,
          Image.asset("assets/tutorial_asset_2.png", fit: BoxFit.contain),
        ),
      ],
    );
  }

  Widget _bordered(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
      child: child,
    );
  }

  Future<void> _openDataRequestLink(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      if (await launchUrl(uri)) {
        await restartEmailReminderCampaign();
      }
    }
  }
}
