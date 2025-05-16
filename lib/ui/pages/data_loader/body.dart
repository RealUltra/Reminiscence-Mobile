import 'package:flutter/material.dart';

import 'package:reminiscence/ui/pages/data_loader/load_button.dart';
import 'package:reminiscence/ui/pages/data_loader/no_recent_files_widget.dart';
import 'package:reminiscence/ui/pages/data_loader/recent_files_list.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final List<String> recentFiles = [
    "/storage/documents/reports/Annual Report 2024.rem",
    "/storage/notes/meetings/rameezheree.rem",
    "/storage/notes/meetings/documents/reports/notes/meetings/instagram_rameezheree_2024-12-16.rem",
    "/storage/documents/reports/Annual Report 2024.rem",
    "/storage/notes/meetings/rameezheree.rem",
    "/storage/documents/reports/Annual Report 2024.rem",
    "/storage/notes/meetings/rameezheree.rem",
    "/storage/documents/reports/Annual Report 2024.rem",
    "/storage/notes/meetings/rameezheree.rem",
    "/storage/documents/reports/Annual Report 2024.rem",
    "/storage/notes/meetings/rameezheree.rem",
  ];

  @override
  Widget build(BuildContext context) {
    //recentFiles.clear();

    return Padding(
      padding: EdgeInsets.fromLTRB(24.0, 0, 24.0, 0),
      child: Column(
        children: [
          const SizedBox(height: 6),
          const LoadDataButton(),
          SizedBox(height: (recentFiles.isNotEmpty ? 32 : 50)),
          recentFiles.isNotEmpty
              ? RecentFilesList(recentFiles: recentFiles)
              : const NoRecentFilesWidget(),
        ],
      ),
    );
  }
}
