import 'package:flutter/material.dart';

import 'package:reminiscence/ui/pages/data_loader/file_card.dart';

class FilesList extends StatefulWidget {
  final Map<String, DateTime?> recentFiles;
  final void Function(String filePath)? onClick;
  final Future<void> Function(String filePath)? onDelete;

  const FilesList({
    super.key,
    required this.recentFiles,
    this.onClick,
    this.onDelete,
  });

  @override
  State<FilesList> createState() => _FilesListState();
}

class _FilesListState extends State<FilesList> {
  @override
  Widget build(BuildContext context) {
    final filePaths = widget.recentFiles.keys.toList();

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
                      lastOpened: widget.recentFiles[filePaths[index]],
                      onClick: widget.onClick ?? (_) {},
                      onDelete: onDelete,
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

  Future<void> onDelete(String filePath) async {
    final mustDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Are you sure?'),
              content: Text(
                'This file is about to be permanently deleted from your device.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!mustDelete) {
      return;
    }

    if (widget.onDelete != null) {
      await widget.onDelete!(filePath);
    }
  }
}
