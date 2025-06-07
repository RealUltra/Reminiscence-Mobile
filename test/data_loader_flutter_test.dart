//import 'dart:developer';
//import 'dart:io';
//import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
//import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

import 'package:reminiscence/features/data_loader/rem_generator.dart';
//import 'package:reminiscence/features/data_loader/data_archive_loader/data_archive_loader.dart';
//import 'package:reminiscence/features/data_loader/data_archive_loader/models/chat.dart';
//import 'package:reminiscence/features/data_loader/data_archive_loader/models/message_stack.dart';
//import 'package:reminiscence/features/data_loader/data_archive_loader/models/message.dart';
//import 'package:reminiscence/features/data_loader/data_archive_loader/models/attachment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  List<Permission> permissions = [Permission.storage];

  await permissions.request();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Data Loader Test', home: const Home());
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.red,
        child: TextButton(
          onPressed: _pickFile,
          child: Text(
            "Upload your instagram data zip file.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String filePath = result.files.single.path!;

      final start = DateTime.now();
      final tempPath = await createRemFile(
        archivePath: filePath,
        password: null,
      );
      debugPrint(
        "Duration: ${DateTime.now().difference(start).inMilliseconds}",
      );
    }
  }
}
