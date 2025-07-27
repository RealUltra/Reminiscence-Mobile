import 'package:flutter/material.dart';

class InfoBox extends StatelessWidget {
  final String title;
  final String body;
  final List<InfoBoxButton> actions;
  final double maxTextHeight;

  const InfoBox({
    super.key,
    required this.title,
    this.body = "",
    this.actions = const [
      InfoBoxButton("OK", highlighted: true),
    ],
    this.maxTextHeight = 400.0,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 2.0,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceContainerHighest,

      child: Container(
        padding: EdgeInsets.fromLTRB(32.0, 48.0, 32.0, 24.0),
        
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,

          border: BoxBorder.symmetric(
            horizontal: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 32.0,

          children: [
            Text(
              title.toUpperCase(),

              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxTextHeight),

              child: Scrollbar(
                thumbVisibility: true,

                child: Padding(
                  padding: EdgeInsets.only(right: 24.0),
                  child: SingleChildScrollView(
                    child: Text(body, textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8.0,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}

class InfoBoxButton extends StatelessWidget {
  final String text;
  final bool highlighted;
  final dynamic value;

  const InfoBoxButton(
    this.text, {
    super.key,
    this.highlighted = true,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        highlighted
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest;

    final foregroundColor =
        highlighted
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(value),

      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        width: double.infinity,

        decoration: BoxDecoration(
          color: backgroundColor,
          border: BoxBorder.all(color: foregroundColor),
          borderRadius: BorderRadius.circular(8.0),
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
    );
  }
}
