import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:reminiscence/features/reminiscence_file_io/reminiscence_file.dart';
import 'package:share_plus/share_plus.dart';

import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/attachment_dto.dart';
import 'package:reminiscence/features/database/tables/attachment_type.dart';
import 'package:reminiscence/features/encryption/encryption.dart';
import 'package:reminiscence/ui/components/audio_player_widget.dart';
import 'package:reminiscence/ui/components/file_widget.dart';
import 'package:reminiscence/ui/components/link_preview.dart';
import 'package:reminiscence/ui/components/video_player_widget.dart';

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
  bool isReady = false;

  @override
  void initState() {
    super.initState();

    if (widget.attachment.type != AttachmentType.link) {
      _prepareFile();
    } else {
      setState(() => isReady = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return CircularProgressIndicator();
    }

    if (widget.attachment.type == AttachmentType.photo) {
      return _buildPhoto();
    } else if (widget.attachment.type == AttachmentType.audio) {
      return _buildAudio();
    } else if (widget.attachment.type == AttachmentType.file) {
      return _buildFile();
    } else if (widget.attachment.type == AttachmentType.video) {
      return _buildVideo();
    } else {
      return _buildLink();
    }
  }

  Widget _buildPhoto() {
    final imageFile = File(_getFilePath());

    if (!imageFile.existsSync()) {
      return CircularProgressIndicator();
    }

    if (imageFile.lengthSync() <= 0) {
      imageFile.deleteSync();
      _prepareFile();
      return CircularProgressIndicator();
    }

    return GestureDetector(
      onTap: () => launchFile(),
      child: Image.file(imageFile, width: 300, fit: BoxFit.cover),
    );
  }

  Widget _buildAudio() {
    final audioFile = File(_getFilePath());

    if (!audioFile.existsSync()) {
      return CircularProgressIndicator();
    }

    return Container(
      margin: EdgeInsets.only(top: 8),
      child: AudioPlayerWidget(audioFile.path, onShare: shareFile),
    );
  }

  Widget _buildFile() {
    final file = File(_getFilePath());

    if (!file.existsSync()) {
      return CircularProgressIndicator();
    }

    return GestureDetector(
      onTap: () => launchFile(),
      child: FileWidget(p.basename(widget.attachment.uri)),
    );
  }

  Widget _buildVideo() {
    String videoPath = _getFilePath();

    if (!File(videoPath).existsSync()) {
      return CircularProgressIndicator();
    }

    return Container(
      margin: EdgeInsets.only(top: 8),
      child: VideoPlayerWidget(File(videoPath), onShare: shareFile),
    );
  }

  Widget _buildLink() {
    return LinkPreview(widget.attachment.uri);
  }

  Future<void> launchFile() async {
    final file = File(_getFilePath());

    String tempFilename = p.basename(widget.attachment.uri) + _getExtension();

    final tempDir = await getTemporaryDirectory();
    final tempPath = p.join(tempDir.path, tempFilename);

    await file.copy(tempPath);

    await OpenFile.open(tempPath);
  }

  Future<void> shareFile() async {
    final file = File(_getFilePath());

    String tempFilename =
        p.basenameWithoutExtension(widget.attachment.uri) + _getExtension();

    final tempDir = await getTemporaryDirectory();
    final tempPath = p.join(tempDir.path, tempFilename);

    await file.copy(tempPath);

    await SharePlus.instance.share(ShareParams(files: [XFile(tempPath)]));
  }

  String _getFilePath() {
    return p.join(widget.data.tempDir.path, "media_${widget.attachment.id}");
  }

  String _getExtension() {
    if (widget.attachment.type == AttachmentType.photo) {
      return ".jpg";
    } else if (widget.attachment.type == AttachmentType.audio) {
      return ".mp3";
    } else {
      return p.extension(widget.attachment.uri);
    }
  }

  Future<void> _prepareFile() async {
    final file = File(_getFilePath());

    if (!(await file.exists())) {
      final remFile = ReminiscenceFile();
      remFile.pageHeaderCache = widget.data.file.pageHeaderCache;
      await remFile.open(widget.data.file.name);

      if (widget.data.secretKey == null) {
        await remFile.readMediaToFile(widget.attachment.id, file);

      } else {
        final stream = remFile.readMedia(widget.attachment.id);
        await decryptStream(stream: stream, outputFile: file, secretKey: widget.data.secretKey!);
      }

      await remFile.close();
    }

    // Update the widget to render the attachment
    if (mounted) {
      setState(() => isReady = true);
    }

    /*
    // If the file is not encrypted, exit the function.
    if (widget.data.secretKey == null) {
      return;
    }

    final decryptedPath = _getDecryptedFilePath();
    final decryptedFile = File(decryptedPath);

    // If the decrypted file already exists, exit the function.
    if (await decryptedFile.exists()) {
      // Update the widget to render the attachment
      if (mounted) {
        setState(() {});
      }
      return;
    }

    // Decrypt the file.
    final stream = InputFileStream(encryptedPath);

    await decryptStream(
      inputStream: stream,
      outputPath: decryptedPath,
      secretKey: widget.data.secretKey!,
    );

    // Update the widget to render the attachment
    if (mounted) {
      setState(() {});
    }
  */
  }
}
