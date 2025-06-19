import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/attachment_dto.dart';
import 'package:reminiscence/features/database/models/attachment_type.dart';
import 'package:reminiscence/features/encryption/encryption.dart';
import 'package:reminiscence/ui/pages/chat/audio_player_widget.dart';
import 'package:reminiscence/ui/pages/chat/file_widget.dart';

class AttachmentWidget extends StatefulWidget {
  final AttachmentDto attachment;
  final ReminiscenceData data;

  const AttachmentWidget({
    super.key,
    required this.attachment,
    required this.data,
  });

  @override
  State<AttachmentWidget> createState() => _AttachmentWidgetState();
}

class _AttachmentWidgetState extends State<AttachmentWidget> {
  @override
  void initState() {
    super.initState();

    if (widget.attachment.type == AttachmentType.photo ||
        widget.attachment.type == AttachmentType.audio) {
      _prepareFile();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.attachment.type == AttachmentType.photo) {
      return _buildPhoto();
    } else if (widget.attachment.type == AttachmentType.audio) {
      return _buildAudio();
    } else if (widget.attachment.type == AttachmentType.file) {
      return _buildFile();
    }

    return Container();
  }

  Widget _buildPhoto() {
    String imagePath = _getFilePath();

    if (!File(imagePath).existsSync()) {
      return CircularProgressIndicator();
    }

    return GestureDetector(
      onTap: () => launchFile(),
      child: Image.file(File(imagePath), width: 300, fit: BoxFit.cover),
    );
  }

  Widget _buildAudio() {
    String audioPath = _getFilePath();

    if (!File(audioPath).existsSync()) {
      return CircularProgressIndicator();
    }

    return Container(
      margin: EdgeInsets.only(top: 8),
      child: AudioPlayerWidget(audioPath),
    );
  }

  Widget _buildFile() {
    String filePath = _getFilePath();

    if (!File(filePath).existsSync()) {
      return CircularProgressIndicator();
    }

    return GestureDetector(
      onTap: () => launchFile(),
      child: FileWidget(p.basename(widget.attachment.uri)),
    );
  }

  Future<void> launchFile() async {
    final file = File(_getFilePath());

    String tempFilename = p.basename(widget.attachment.uri);

    if (widget.attachment.type == AttachmentType.photo) {
      tempFilename += ".jpg";
    } else if (widget.attachment.type == AttachmentType.audio) {
      tempFilename += ".mp3";
    }

    final tempDir = await getTemporaryDirectory();
    final tempPath = p.join(tempDir.path, tempFilename);

    await file.copy(tempPath);

    await OpenFile.open(tempPath);
  }

  String _getFilePath() {
    if (widget.data.secretKey == null) {
      return p.join(widget.data.mediaDir.path, "${widget.attachment.id}");
    } else {
      return p.join(
        widget.data.mediaDir.path,
        "${widget.attachment.id}_decrypted",
      );
    }
  }

  Future<void> _prepareFile() async {
    // If the photo is not encrypted, exit the function.
    if (widget.data.secretKey == null) {
      return;
    }

    final encryptedPath = p.join(
      widget.data.mediaDir.path,
      "${widget.attachment.id}",
    );

    final decryptedPath = p.join(
      widget.data.mediaDir.path,
      "${widget.attachment.id}_decrypted",
    );

    final decryptedFile = File(decryptedPath);

    // If the decrypted file already exists, exit the function.
    if (await decryptedFile.exists()) {
      return;
    }

    // Decrypt the file.
    final stream = InputFileStream(encryptedPath);

    await decryptStream(
      inputStream: stream,
      outputPath: encryptedPath,
      secretKey: widget.data.secretKey!,
    );

    // Update the widget to render the attachment
    setState(() {});
  }
}
