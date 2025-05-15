import 'package:flutter/material.dart';

import "package:path/path.dart" as p;

class RecentFileCard extends StatelessWidget {
  final String filePath;

  const RecentFileCard({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    String dir = "${p.dirname(filePath)}/";
    String fileName = p.basenameWithoutExtension(filePath);

    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 4, 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
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
                  dir,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
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
    );
  }
}
