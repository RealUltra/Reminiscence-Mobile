import 'package:flutter/material.dart';

import "package:path/path.dart" as p;
import 'package:reminiscence/features/data_loader/utils.dart';

class FileCard extends StatelessWidget {
  final String filePath;
  final DateTime? lastOpened;
  late final bool isEncrypted;
  final void Function(String) onClick;

  FileCard({
    super.key,
    required this.filePath,
    required this.lastOpened,
    required this.onClick,
  }) {
    isEncrypted = isRemFileEncrypted(filePath);
  }

  @override
  Widget build(BuildContext context) {
    //String dir = "${p.dirname(filePath)}/";
    String fileName = p.basenameWithoutExtension(filePath);

    return GestureDetector(
      onTap: () => onClick(filePath),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 4, 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    lastOpened == null
                        ? ""
                        : "Last Opened: ${_formatDateTime(lastOpened!)}",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
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
