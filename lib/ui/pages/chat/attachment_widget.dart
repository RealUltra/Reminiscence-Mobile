import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/attachment_dto.dart';
import 'package:reminiscence/features/database/models/attachment_type.dart';
import 'package:reminiscence/features/encryption/encryption.dart';

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

    if (widget.attachment.type == AttachmentType.photo) {
      _preparePhoto();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.attachment.type == AttachmentType.photo) {
      return _buildPhoto();
    }

    return Container();
  }

  Widget _buildPhoto() {
    String imagePath;

    if (widget.data.secretKey == null) {
      imagePath = p.join(widget.data.mediaDir.path, "${widget.attachment.id}");
    } else {
      imagePath = p.join(
        widget.data.mediaDir.path,
        "${widget.attachment.id}_decrypted",
      );

      if (!File(imagePath).existsSync()) {
        return CircularProgressIndicator();
      }
    }

    return Image.file(File(imagePath));
  }

  Future<void> _preparePhoto() async {
    // If the photo is not encrypted, exit the function.
    if (widget.data.secretKey == null) {
      return;
    }

    final encryptedImagePath = p.join(
      widget.data.mediaDir.path,
      "${widget.attachment.id}",
    );

    final imagePath = p.join(
      widget.data.mediaDir.path,
      "${widget.attachment.id}_decrypted",
    );

    final imageFile = File(imagePath);

    // If the decrypted file already exists, exit the function.
    if (await imageFile.exists()) {
      return;
    }

    // Decrypt the file.
    final stream = InputFileStream(encryptedImagePath);

    await decryptStream(
      inputStream: stream,
      outputPath: imagePath,
      secretKey: widget.data.secretKey!,
    );

    // Update the image
    setState(() {});
  }
}
