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
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            fileName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            dir,
            style: TextStyle(color: Colors.grey, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
