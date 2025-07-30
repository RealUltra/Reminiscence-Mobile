import 'package:flutter/material.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkPreview extends StatefulWidget {
  final String link;

  const LinkPreview(this.link, {super.key});

  @override
  State<LinkPreview> createState() => _LinkPreviewState();
}

class _LinkPreviewState extends State<LinkPreview> {
  bool canLaunch = false;

  @override
  void initState() {
    super.initState();

    canLaunchUrl(Uri.parse(widget.link)).then((value) {
      setState(() => canLaunch = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(widget.link);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),

      child: AnyLinkPreview(
        link: widget.link,
        cache: const Duration(days: 1),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        displayDirection: UIDirection.uiDirectionHorizontal,

        titleStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),

        bodyStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),

        errorWidget: GestureDetector(
          onTap: () async {
            if (canLaunch) {
              launchUrl(uri);
            } else {
              Clipboard.setData(ClipboardData(text: widget.link));
            }
          },

          child: Container(
            padding: const EdgeInsets.all(4.0),

            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8.0),
            ),

            child: ListTile(
              leading: const Icon(Icons.language),

              title: Text(
                "Unable to preview link",

                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),

              subtitle: Text(
                canLaunch
                    ? "Click here to launch the url."
                    : "Click here to copy the url.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
