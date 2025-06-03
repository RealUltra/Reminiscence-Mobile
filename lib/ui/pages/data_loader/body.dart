import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart' as drift;
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
import 'package:reminiscence/features/data_loader/utils.dart';
import 'package:reminiscence/ui/components/bullet_point.dart';

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

  Future<void> loadData(BuildContext context, String filePath) async {
    final extension = path.extension(filePath);

    if (extension == ".rem") {
      await loadRemData(context, filePath);
    } else if (extension == ".zip") {
      await loadZipData(context, filePath);
    } else {
      debugPrint("Invalid file type!");
    }
  }

  Future<void> loadRemData(
    BuildContext context,
    String filePath, {
    String? password,
  }) async {
    // If the file is encrypted but there is no password given, prompt for a password.
    // If the user closes the password prompt, exit the function.
    if (isRemFileEncrypted(filePath)) {
      password ??= await _promptPassword(
        context,
        1,
        checkPassword: (String password) async {
          return await checkPassword(
            filePath,
            password.isEmpty ? null : password,
          );
        },
      );
      if (password == null) return;
    } else {
      password = "";
    }

    password = password.isEmpty ? null : password;

    if (!context.mounted) return;

    // Load the rem file with the loading screen.
    Map<String, dynamic>? dataMap = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => LoadingScreen<Map<String, dynamic>>(
              operation: loadRemFileForIsolate,
              operationParams: <dynamic>[filePath, password],
            ),
      ),
    );

    // If the rem file loading failed, exit.
    if (dataMap == null) return;

    // Load the database.
    final data = ReminiscenceData.fromMap(dataMap);
    data.loadDatabase();

    final chats = await data.db.chats.select().get();
    debugPrint("Chat: ${chats[0]}");

    debugPrint("REM FILE LOADED!");
  }

  Future<void> loadZipData(BuildContext context, String filePath) async {
    // Check if the zip file selected is valid.
    if (!isValidArchive(archivePath: filePath)) {
      debugPrint("Invalid archive!");
      return;
    }

    if (!context.mounted) return;

    // If no password has been given, prompt for a password.
    String? password = await _promptPassword(context, 0);

    // If the user closes the password prompt, exit the function.
    if (password == null) return;

    // If the password is an empty string, it equates to no password i.e password = null
    password = password.isEmpty ? null : password;

    if (!context.mounted) return;

    // Create a rem file with a loading screen.
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

    // Save the file in my applications directory.
    final remFilePath = await saveNewRemFile(outputPath);

    if (!context.mounted) return;

    // Load the rem file.
    //await loadRemData(context, remFilePath, password: password);

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Disclaimer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BulletPoint(
                  "A .rem file has been created using your instagram data.",
                ),
                const SizedBox(height: 8),
                BulletPoint(
                  "Please delete the zip file containing your instagram data as it poses security risks.",
                  textStyle: TextStyle(color: Colors.redAccent),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );

    if (!context.mounted) return;

    // Load the rem file.
    await loadRemData(context, remFilePath, password: password);
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

  Future<String?> _promptPassword(
    BuildContext context,
    int mode, {
    Future<bool> Function(String password)? checkPassword,
  }) async {
    final password = await showDialog<String?>(
      context: context,
      builder: (context) {
        return PasswordEntryDialog(mode, checkPassword: checkPassword);
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

  sendPort.send({
    "type": "result",
    "result": outputPath,
    "success": outputPath != null,
  });
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
    rootToken: rootToken,
    sendPort: sendPort,
  );

  sendPort.send({
    "type": "result",
    "result": data?.map,
    "success": data != null,
  });
}
