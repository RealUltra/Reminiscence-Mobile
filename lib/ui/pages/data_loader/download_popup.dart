import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/message_box.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadPopup extends StatelessWidget {
  const DownloadPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(
      "https://accountscenter.instagram.com/info_and_permissions/dyi?source=external&account_type=1&format=JSON&locale_override=en_US",
    );

    return MessageBox(
      title: "Retrieve Your Data",
      body: Column(
        spacing: 16.0,
        children: [
          Image.asset("assets/tutorial_asset_1.png", fit: BoxFit.contain),
          Image.asset("assets/tutorial_asset_2.png", fit: BoxFit.contain),

          GestureDetector(
            onTap: () => launchUrl(uri),
            child: Text(
              "Click here to request your Instagram data, then select these settings.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
                decorationColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      actions: [MessageBoxButton("Done")],
    );
  }
}
