import 'package:flutter/material.dart';

import 'package:reminiscence/ui/pages/data_loader/load_button.dart';
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
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 6),
          const LoadDataButton(),
          SizedBox(height: (recentFiles.isNotEmpty ? 32 : 50)),
          recentFiles.isNotEmpty
              ? RecentFilesList(recentFiles: recentFiles)
              : Column(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 90,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Use the \"Load New File\" button\nto load your instagram data\nand get started!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Need help downloading your instagram data?\nClick here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}
