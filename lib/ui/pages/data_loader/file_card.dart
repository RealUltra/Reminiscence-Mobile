import 'package:flutter/material.dart';
import "package:path/path.dart" as p;

class FileCard extends StatelessWidget {
  final String filePath;
  final DateTime? lastOpened;
  final bool isEncrypted;
  final void Function(String) onClick;
  final void Function(String) onShare;
  final void Function(String) onDelete;

  FileCard({
    super.key,
    required this.filePath,
    required this.lastOpened,
    required this.isEncrypted,
    required this.onClick,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    //String dir = "${p.dirname(filePath)}/";
    String fileName = p.basenameWithoutExtension(filePath);

    return GestureDetector(
      onTap: () => onClick(filePath),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 4, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Icon(isEncrypted ? Icons.lock : Icons.lock_open),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    lastOpened == null
                        ? ""
                        : "Last Opened: ${_formatDateTime(lastOpened!)}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: MenuAnchor(
                builder: (
                  BuildContext context,
                  MenuController controller,
                  Widget? child,
                ) {
                  return IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                  );
                },
                menuChildren: getOptionsMenuChildren(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<MenuItemButton> getOptionsMenuChildren(BuildContext context) {
    return [
      MenuItemButton(
        onPressed: () => onShare(filePath),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.ios_share,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              "Export",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      ),

      MenuItemButton(
        onPressed: () => onDelete(filePath),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            Text(
              "Delete",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      ),
    ];
  }

  String _formatDateTime(DateTime dateTime) {
    // 03/06/2024 10:15
    final day = dateTime.day.toString().padLeft(2, "0");
    final month = dateTime.month.toString().padLeft(2, "0");
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, "0");
    final minute = dateTime.minute.toString().padLeft(2, "0");

    return "$day/$month/$year $hour:$minute";
  }
}
