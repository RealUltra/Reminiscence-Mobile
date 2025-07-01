import 'package:flutter/material.dart';
import 'package:any_link_preview/any_link_preview.dart';

class LinkPreview extends StatefulWidget {
  final String link;

  const LinkPreview(this.link, {super.key});

  @override
  State<LinkPreview> createState() => _LinkPreviewState();
}

class _LinkPreviewState extends State<LinkPreview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.0),

      child: AnyLinkPreview(
        link: widget.link,

        cache: const Duration(days: 1),

        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,

        titleStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),

        bodyStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),

        displayDirection: UIDirection.uiDirectionHorizontal,
      ),
    );
  }
}
