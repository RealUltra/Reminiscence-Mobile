import 'package:flutter/material.dart';

import 'package:reminiscence/ui/pages/data_loader/recent_file_card.dart';

class RecentFilesList extends StatelessWidget {
  final List<String> recentFiles;

  const RecentFilesList({super.key, required this.recentFiles});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Recent Files",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemCount: recentFiles.length,
              itemBuilder:
                  (BuildContext context, int index) =>
                      RecentFileCard(filePath: recentFiles[index]),
              separatorBuilder:
                  (BuildContext context, int index) =>
                      const SizedBox(height: 12),
            ),
          ),
        ],
      ),
    );
  }
}
