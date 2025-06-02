import 'dart:io';
import 'dart:isolate';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:reminiscence/features/data_loader/data_archive_loader/utils.dart';
import 'package:reminiscence/features/data_loader/data_loader.dart';
import 'package:reminiscence/features/data_loader/rem_generator.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';

import 'package:reminiscence/ui/pages/data_loader/load_button.dart';
import 'package:reminiscence/ui/pages/data_loader/no_recent_files_widget.dart';
import 'package:reminiscence/ui/pages/data_loader/password_entry_dialog.dart';
import 'package:reminiscence/ui/pages/data_loader/recent_files_list.dart';
import 'package:reminiscence/ui/pages/loading_screen/loading_screen.dart';

class Body extends StatefulWidget {
  final MediaStore mediaStorePlugin;

  const Body(this.mediaStorePlugin, {super.key});

  @override
  State<Body> createState() => BodyState();
}

class BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.0, 0, 24.0, 0),
      child: Column(
        children: [
          const SizedBox(height: 6),
          LoadDataButton(parent: this),
          FutureBuilder<List<String>>(
            future: fetchRecentFiles(),
            builder: (context, snapshot) {
              const noRecentFilesWidget = Expanded(
                child: Column(
                  children: [SizedBox(height: 50), NoRecentFilesWidget()],
                ),
              );

              if (snapshot.connectionState == ConnectionState.waiting) {
                return noRecentFilesWidget;
              } else if (snapshot.hasError) {
                return noRecentFilesWidget;
              } else if (snapshot.hasData) {
                final List<String> recentFiles = snapshot.data!;

                return Expanded(
                  child: Column(
                    children: [
                      SizedBox(height: (recentFiles.isNotEmpty ? 32 : 50)),
                      recentFiles.isNotEmpty
                          ? RecentFilesList(
                            recentFiles: recentFiles,
                            onClick:
                                (String filePath) =>
                                    loadData(context, filePath),
                          )
                          : const NoRecentFilesWidget(),
                    ],
                  ),
                );
              } else {
                return noRecentFilesWidget;
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> loadNewData(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null) {
      final file = result.files.single;
      final filePath = file.path!;

      if (context.mounted) {
        await loadData(context, filePath);
      }
    }
  }

  Future<void> loadData(
    BuildContext context,
    String filePath, {
    String? password,
  }) async {
    final extension = path.extension(filePath);

    if (extension == ".rem") {
      Map<String, dynamic>? dataMap = await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => LoadingScreen<Map<String, dynamic>>(
                operation: loadRemFileForIsolate,
                operationParams: <dynamic>[filePath, password],
              ),
        ),
      );

      if (dataMap == null) return;

      final data = ReminiscenceData.fromMap(dataMap);
      data.loadDatabase();

      debugPrint("REM FILE LOADED!");
    } else if (extension == ".zip") {
      if (!isValidArchive(archivePath: filePath)) {
        debugPrint("Invalid archive!");
        return;
      }

      if (!context.mounted) return;

      password ??= await _promptPassword(context);
      if (password == null) return;
      password = password.isEmpty ? null : password;

      if (!context.mounted) return;

      String? outputPath = await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => LoadingScreen<String>(
                operation: createRemFileForIsolate,
                operationParams: <dynamic>[filePath, password],
              ),
        ),
      );

      if (outputPath == null) return;

      final remFilePath = await saveNewRemFile(outputPath);

      if (!context.mounted) return;

      await loadData(context, remFilePath, password: password);
    } else {
      debugPrint("Invalid file type!");
    }
  }

  Future<String> saveNewRemFile(String tempPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = path.join(directory.path, path.basename(tempPath));

    final tempFile = File(tempPath);
    await tempFile.rename(filePath);

    debugPrint("Data Loaded Successfully: $filePath");

    setState(() {});

    return filePath;
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

  Future<List<String>> fetchRecentFiles() async {
    final List<String> recentFiles = [];

    final directory = await getApplicationDocumentsDirectory();

    await for (FileSystemEntity entity in directory.list()) {
      if (entity is File) {
        File file = entity;

        if (path.extension(file.path) == ".rem") {
          recentFiles.add(file.path);
        }
      }
    }

    debugPrint("$recentFiles");

    return recentFiles;
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

Future<void> loadRemFileForIsolate(List<dynamic> args) async {
  /*
  This function runs the `loadRemFile` (See data_loader) function but takes arguments in a way that allows `Isolate.spawn` (See LoadingScreen) to call it.
  */

  final String filePath = args[0];
  final String? password = args[1];
  final RootIsolateToken rootToken = args[2];
  final SendPort sendPort = args[3];

  BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);

  ReminiscenceData? data = await loadRemFile(
    filePath: filePath,
    password: password,
    sendPort: sendPort,
  );

  sendPort.send({
    "type": "result",
    "result": data?.map,
    "success": data != null,
  });
}
