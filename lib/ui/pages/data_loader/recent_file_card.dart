import 'package:flutter/material.dart';

import "package:path/path.dart" as p;
import 'package:reminiscence/features/data_loader/utils.dart';

class RecentFileCard extends StatelessWidget {
  final String filePath;
  late final bool isEncrypted;

  RecentFileCard({super.key, required this.filePath}) {
    isEncrypted = isRemFileEncrypted(filePath);
  }

  @override
  Widget build(BuildContext context) {
    //String dir = "${p.dirname(filePath)}/";
    String fileName = p.basenameWithoutExtension(filePath);

    return Container(
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
            child: Text(
              fileName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
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
    );
  }
}
