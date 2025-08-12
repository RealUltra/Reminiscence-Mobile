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

const double attachmentHeight = 300.0;

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
    final ready = imageFile.existsSync() && imageFile.lengthSync() > 0;

    return SizedBox(
      height: attachmentHeight,
      width: double.infinity,
      child:
          ready
              ? GestureDetector(
                key: ValueKey("image"),
                onTap: () => launchFile(),
                child: Image.file(
                  imageFile,
                  height: attachmentHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
              : const Center(
                key: ValueKey("placeholder"),
                child: CircularProgressIndicator(),
              ),
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

    return GestureDetector(
      onTap: () {
        if (file.existsSync()) {
          launchFile();
        }
      },
      child: FileWidget(p.basename(widget.attachment.uri)),
    );
  }

  Widget _buildVideo() {
    final placeholderWidget = Center(child: CircularProgressIndicator());

    String videoPath = _getFilePath();
    final ready = File(videoPath).existsSync();

    return Container(
      margin: EdgeInsets.only(top: 8),
      height: 300.0,
      width: double.infinity,
      color: Colors.black,
      child:
          ready
              ? VideoPlayerWidget(
                File(videoPath),
                onShare: shareFile,
                placeholderWidget: placeholderWidget,
              )
              : placeholderWidget,
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
        await remFile.writeMediaToFile(widget.attachment.id, file);
      } else {
        final stream = remFile.readMedia(widget.attachment.id);
        await decryptStream(
          stream: stream,
          outputFile: file,
          secretKey: widget.data.secretKey!,
        );
      }

      await remFile.close();
    }

    // Update the widget to render the attachment
    if (mounted) {
      setState(() => isReady = true);
    }
  }
}
