import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/database/models/attachment_type.dart';
import 'package:reminiscence/ui/pages/search/date_picker_dialog/date_picker_dialog.dart';
import 'package:reminiscence/ui/pages/search/filter_controller.dart';
import 'package:reminiscence/ui/pages/search/list_dialog/list_dialog.dart';
import 'package:reminiscence/ui/providers/session_data.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final FilterController filterController;

  const MyAppBar({super.key, required this.filterController});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      scrolledUnderElevation: 0.0,

      titleSpacing: 2,

      title: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),

        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
            filled: true,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),

      actions: [
        IconButton(
          icon: Icon(Icons.filter_alt_off_rounded, size: 22.0),
          onPressed: () => showFiltersMenu(context),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(64.0);

  Future<void> showFiltersMenu(BuildContext context) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(overlay.size.width, 84, 0, 0),

      items: <PopupMenuEntry<String>>[
        PopupMenuItem(
          value: 'sender',

          child: Row(
            spacing: 12.0,

            children: [
              Icon(Icons.person, size: 15.0),
              Text("From a specific person"),
            ],
          ),
        ),

        PopupMenuItem(
          value: 'attachment',

          child: Row(
            spacing: 12.0,

            children: [
              Icon(Icons.attach_file, size: 15.0),
              Text("Has a particular attachment"),
            ],
          ),
        ),

        PopupMenuItem(
          value: 'sentBefore',

          child: Row(
            spacing: 12.0,

            children: [
              Icon(Icons.date_range, size: 15.0),
              Text("Sent before a certain date"),
            ],
          ),
        ),

        PopupMenuItem(
          value: 'sentOn',

          child: Row(
            spacing: 12.0,

            children: [
              Icon(Icons.calendar_today, size: 15.0),
              Text("Sent on a certain date"),
            ],
          ),
        ),

        PopupMenuItem(
          value: 'sentAfter',

          child: Row(
            spacing: 12.0,

            children: [
              Icon(Icons.date_range, size: 15.0),
              Text("Sent after a certain date"),
            ],
          ),
        ),
      ],
    );

    if (result == null || !context.mounted) {
      return;
    }

    final sessionData = Provider.of<SessionData>(context, listen: false);
    final chat = sessionData.chat!;

    switch (result) {
      case "sender":
        {
          final senderName = await showDialog<String>(
            context: context,
            barrierDismissible: true,
            builder:
                (BuildContext context) =>
                    ListDialog(options: chat.participants),
          );

          if (senderName == null || !context.mounted) {
            return;
          }
        }

      case "attachment":
        {
          final options = AttachmentType.values.map((t) => t.name).toList();

          final attachmentTypeName = await showDialog<String>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) => ListDialog(options: options),
          );

          if (attachmentTypeName == null || !context.mounted) {
            return;
          }

          final index = options.indexOf(attachmentTypeName);
          final attachmentType = AttachmentType.values[index];

          break;
        }

      case "sentBefore":
        {
          final date = await showDialog<DateTime>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) => MyDatePickerDialog(),
          );

          if (date == null || !context.mounted) {
            return;
          }

          break;
        }

      case "sentOn":
        {
          final date = await showDialog<DateTime>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) => MyDatePickerDialog(),
          );

          if (date == null || !context.mounted) {
            return;
          }

          break;
        }

      case "sentAfter":
        {
          final date = await showDialog<DateTime>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) => MyDatePickerDialog(),
          );

          if (date == null || !context.mounted) {
            return;
          }

          break;
        }
    }
  }
}
