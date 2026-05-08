import 'package:flutter/material.dart';
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
          onTap: () async {
            if (await canLaunchUrl(uri)) {
              launchUrl(uri);
            }
          },
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
}
