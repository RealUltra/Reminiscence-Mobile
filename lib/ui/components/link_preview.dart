import 'package:flutter/material.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkPreview extends StatefulWidget {
  final String link;

  const LinkPreview(this.link, {super.key});

  @override
  State<LinkPreview> createState() => _LinkPreviewState();
}

class _LinkPreviewState extends State<LinkPreview> {
  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(widget.link);
    final double previewHeight = 120.0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),

      constraints: BoxConstraints(maxWidth: 400),

      child: AnyLinkPreview(
        link: widget.link,
        cache: const Duration(days: 1),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        displayDirection: UIDirection.uiDirectionHorizontal,

        previewHeight: previewHeight,
        titleStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),

        bodyStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),

        errorWidget: GestureDetector(
          onTap: () async {
            await launchUrl(uri);
          },

          child: Container(
            height: previewHeight,
            padding: EdgeInsets.symmetric(horizontal: 24.0),

            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.0),

              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1.0,
              ),
            ),

            child: Row(
              spacing: 24.0,

              children: [
                Icon(
                  Icons.link_off_rounded,
                  size: previewHeight * 0.35,
                  color: Theme.of(context).colorScheme.primary,
                ),

                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4.0,

                    children: [
                      Text(
                        "Unable to preview link",
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      Text(
                        "Tap to open in browser",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
