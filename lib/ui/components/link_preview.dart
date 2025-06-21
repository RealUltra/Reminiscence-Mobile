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
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(widget.link)),

      child: AnyLinkPreview.builder(
        link: widget.link,
        cache: Duration(days: 30),

        itemBuilder: (context, metadata, imageProvider, icon) {
          return Container(
            width: 200,
            margin: EdgeInsets.symmetric(vertical: 2.0),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
            ),

            child: Column(
              children: [
                imageProvider != null
                    ? Image(image: imageProvider, fit: BoxFit.cover)
                    : Container(),

                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        metadata.title ?? "No Title",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        metadata.desc ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
