import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OneClickBody extends StatelessWidget {
  const OneClickBody({super.key});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(
      "https://accountscenter.instagram.com/info_and_permissions/dyi?source=external&account_type=1&format=JSON&locale_override=en_US",
    );

    return Column(
      spacing: 16.0,
      children: [
        GestureDetector(
          onTap: () => launchUrl(uri),
          child: Text(
            "Click here to request your Instagram data, then select the following settings.",
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

        Image.asset("assets/tutorial_asset_1.png", fit: BoxFit.contain),
        Image.asset("assets/tutorial_asset_2.png", fit: BoxFit.contain),
      ],
    );
  }
}
