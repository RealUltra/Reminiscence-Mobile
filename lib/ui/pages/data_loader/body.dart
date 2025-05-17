import 'dart:isolate';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reminiscence/features/data_loader/data_archive_loader/utils.dart';
import 'package:reminiscence/features/data_loader/rem_generator.dart';

import 'package:reminiscence/ui/pages/data_loader/load_button.dart';
import 'package:reminiscence/ui/pages/data_loader/no_recent_files_widget.dart';
import 'package:reminiscence/ui/pages/data_loader/password_entry_dialog.dart';
import 'package:reminiscence/ui/pages/data_loader/recent_files_list.dart';
import 'package:reminiscence/ui/pages/loading_screen/loading_screen.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => BodyState();
}

class BodyState extends State<Body> {
  final List<String> recentFiles = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.0, 0, 24.0, 0),
      child: Column(
        children: [
          const SizedBox(height: 6),
          LoadDataButton(parent: this),
          SizedBox(height: (recentFiles.isNotEmpty ? 32 : 50)),
          recentFiles.isNotEmpty
              ? RecentFilesList(recentFiles: recentFiles)
              : const NoRecentFilesWidget(),
        ],
      ),
    );
  }

  Future<void> loadData(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null) {
      final file = result.files.single;
      final filePath = file.path!;
      final extension = file.extension!;

      if (extension == "rem") {
        debugPrint("REM FILE!");
      } else if (extension == "zip") {
        if (isValidArchive(archivePath: filePath)) {
          debugPrint("Invalid archive!");
          return;
        }

        if (!context.mounted) return;

        String? password = await _promptPassword(context);
        if (password == null) return;
        password = password.isEmpty ? null : password;

        if (!context.mounted) return;

        String? outputPath = await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => LoadingScreen(
                  operation: createRemFileForIsolate,
                  operationParams: <dynamic>[filePath, password],
                ),
          ),
        );

        if (outputPath == null) return;

        await saveNewRemFile(outputPath);
      } else {
        debugPrint("Invalid file type!");
      }
    }
  }

  Future<void> saveNewRemFile(String tempPath) async {
    debugPrint("Data Loaded Successfully: $tempPath");
  }

  Future<String?> _promptPassword(BuildContext context) async {
    final password = await showDialog<String?>(
      context: context,
      builder: (context) {
        return PasswordEntryDialog();
      },
    );
    return password;
  }
}

Future<void> createRemFileForIsolate(List<dynamic> args) async {
  /*
  This function runs the `createRemFile` (See rem_generator) function but takes arguments in a way that allows `Isolate.spawn` (See LoadingScreen) to call it.
  */

  final String filePath = args[0];
  final String? password = args[1];
  final RootIsolateToken rootToken = args[2];
  final SendPort sendPort = args[3];

  BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);

  String? outputPath = await createRemFile(
    archivePath: filePath,
    password: password,
    rootToken: rootToken,
    sendPort: sendPort,
  );

  sendPort.send({"type": "result", "result": outputPath});
}
