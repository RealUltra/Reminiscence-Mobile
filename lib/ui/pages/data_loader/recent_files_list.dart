import 'package:flutter/material.dart';

import 'package:reminiscence/ui/pages/data_loader/recent_file_card.dart';

class RecentFilesList extends StatelessWidget {
  final List<String> recentFiles;
  final void Function(String filePath) onClick;

  const RecentFilesList({
    super.key,
    required this.recentFiles,
    required this.onClick,
  });

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
            child: ListView.builder(
              itemCount: recentFiles.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    RecentFileCard(
                      filePath: recentFiles[index],
                      onClick: onClick,
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
