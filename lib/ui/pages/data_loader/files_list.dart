import 'package:flutter/material.dart';

import 'package:reminiscence/ui/pages/data_loader/file_card.dart';

class FilesList extends StatelessWidget {
  final Map<String, DateTime?> recentFiles;
  final void Function(String filePath) onClick;

  const FilesList({
    super.key,
    required this.recentFiles,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final filePaths = recentFiles.keys.toList();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Loaded Files",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filePaths.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    FileCard(
                      filePath: filePaths[index],
                      lastOpened: recentFiles[filePaths[index]],
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
