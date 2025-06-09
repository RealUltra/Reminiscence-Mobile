import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'package:reminiscence/features/data_loader/data_archive_loader/utils.dart';
import 'package:reminiscence/features/data_loader/data_loader.dart';
import 'package:reminiscence/features/data_loader/rem_generator.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/data_loader/utils.dart';
import 'package:reminiscence/features/data_storage/data_storage.dart';
import 'package:reminiscence/ui/components/bullet_point.dart';
import 'package:reminiscence/ui/pages/data_loader/load_button.dart';
import 'package:reminiscence/ui/pages/data_loader/no_files_widget.dart';
import 'package:reminiscence/ui/pages/data_loader/password_entry_dialog.dart';
import 'package:reminiscence/ui/pages/data_loader/files_list.dart';
import 'package:reminiscence/ui/pages/loading_screen/loading_screen_args.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => BodyState();
}

class BodyState extends State<Body> {
  late StreamSubscription _intentSub;

  @override
  void initState() {
    super.initState();

    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      if (mounted) {
        loadData(context, value.first.path);
      }
    });
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.0, 0, 24.0, 0),
      child: Column(
        children: [
          const SizedBox(height: 6),
          LoadDataButton(parent: this),
          const SizedBox(height: 50),
          FutureBuilder<Map<String, DateTime?>>(
            future: fetchRecentFiles(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const NoFilesWidget();
              } else if (snapshot.hasError) {
                return const NoFilesWidget();
              } else if (snapshot.hasData) {
                final Map<String, DateTime?> recentFiles = snapshot.data!;

                return recentFiles.isNotEmpty
                    ? FilesList(
                      recentFiles: recentFiles,
                      onClick: (String filePath) => loadData(context, filePath),
                      onDelete: (String filePath) => deleteLoadedFile(filePath),
                    )
                    : const NoFilesWidget();
              } else {
                return const NoFilesWidget();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unrecognized file type.",
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> loadRemData(
    BuildContext context,
    String filePath, {
    String? password,
  }) async {
    // Check if the rem file selected is valid.
    if (!isValidRemFile(filePath)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Invalid rem file.",
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );

      return;
    }

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

    await updateFileHistory(filePath);
    setState(() {});

    if (!context.mounted) return;

    // Load the rem file with the loading screen.
    Map<String, dynamic>? dataMap =
        await Navigator.of(context).pushNamed(
              "/loading",
              arguments: LoadingScreenArgs(
                operation: loadRemFileForIsolate,
                operationParams: <dynamic>[filePath, password],
              ),
            )
            as Map<String, dynamic>?;

    // If the rem file loading failed, exit.
    if (dataMap == null) return;

    // Load the database.
    final data = ReminiscenceData.fromMap(dataMap);
    data.loadDatabase();

    if (!context.mounted) {
      await data.closeDatabase();
      return;
    }

    debugPrint("REM FILE LOADED!");

    await Navigator.of(context).pushNamed("/chats", arguments: data);
  }

  Future<void> loadZipData(BuildContext context, String filePath) async {
    // Check if the zip file selected is valid.
    if (!isValidArchive(archivePath: filePath)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unrecognized zip file format.",
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );

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
    String? outputPath =
        await Navigator.of(context).pushNamed(
              "/loading",
              arguments: LoadingScreenArgs(
                operation: createRemFileForIsolate,
                operationParams: <dynamic>[filePath, password],
              ),
            )
            as String?;

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
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
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

    await updateFileHistory(filePath);
    debugPrint("Data Loaded Successfully: $filePath");

    setState(() {});

    return filePath;
  }

  Future<void> deleteLoadedFile(String filePath) async {
    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
    }

    setState(() {});
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

  Future<Map<String, DateTime?>> fetchRecentFiles() async {
    final Map<String, DateTime?> recentFiles = {};

    final directory = await getApplicationDocumentsDirectory();
    final fileHistory = await getFileHistory();

    await for (FileSystemEntity entity in directory.list()) {
      if (entity is File) {
        File file = entity;
        final filePath = p.normalize(file.path);

        if (path.extension(filePath) == ".rem") {
          final epoch = fileHistory[filePath];
          recentFiles[filePath] =
              epoch != null ? DateTime.fromMillisecondsSinceEpoch(epoch) : null;
        }
      }
    }

    final sortedRecentFiles = Map.fromEntries(
      recentFiles.entries.toList()..sort((a, b) {
        if ((a.value == null) && (b.value == null)) {
          return 0;
        } else if (a.value == null) {
          return -1;
        } else if (b.value == null) {
          return 1;
        } else {
          return b.value!.compareTo(a.value!);
        }
      }),
    );

    debugPrint("$sortedRecentFiles");

    return sortedRecentFiles;
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
