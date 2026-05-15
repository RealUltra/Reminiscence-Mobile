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
import 'package:reminiscence/ui/components/media_widget.dart';

class AttachmentWidget extends StatefulWidget {
  final AttachmentDto attachment;
  final List<AttachmentDto>? mediaAttachments;
  final ReminiscenceData data;

  const AttachmentWidget({
    super.key,
    required this.attachment,
    this.mediaAttachments,
    required this.data,
  });

  @override
  State<AttachmentWidget> createState() => _AttachmentWidgetState();
}

class _AttachmentWidgetState extends State<AttachmentWidget> {
  @override
  void initState() {
    super.initState();
    _prepareAttachmentsIfNeeded();
  }

  @override
  void didUpdateWidget(covariant AttachmentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.attachment.id != widget.attachment.id ||
        !_sameAttachmentIds(
          oldWidget.mediaAttachments,
          widget.mediaAttachments,
        )) {
      _prepareAttachmentsIfNeeded();
    }
  }

  void _prepareAttachmentsIfNeeded() {
    if (widget.attachment.type != AttachmentType.link) {
      _prepareFiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isMediaAttachment(widget.attachment)) {
      return _buildMedia();
    } else if (widget.attachment.type == AttachmentType.audio) {
      return _buildAudio();
    } else if (widget.attachment.type == AttachmentType.file) {
      return _buildFile();
    } else {
      return _buildLink();
    }
  }

  Widget _buildMedia() {
    return MediaWidget(
      items:
          _mediaAttachments.map((attachment) {
            return MediaAttachmentItem(
              type:
                  attachment.type == AttachmentType.photo
                      ? MediaAttachmentType.photo
                      : MediaAttachmentType.video,
              file: File(_getFilePath(attachment)),
              fileName: _getExportFileName(attachment),
              mimeType:
                  attachment.type == AttachmentType.photo
                      ? "image/jpeg"
                      : "video/mp4",
            );
          }).toList(),
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

  Widget _buildLink() {
    return LinkPreview(widget.attachment.uri);
  }

  Future<void> launchFile() async {
    final file = File(_getFilePath(widget.attachment));

    String tempFilename =
        p.basename(widget.attachment.uri) + _getExtension(widget.attachment);

    final tempDir = await getTemporaryDirectory();
    final tempPath = p.join(tempDir.path, tempFilename);

    await file.copy(tempPath);

    await OpenFile.open(tempPath);
  }

  Future<void> shareFile() async {
    final file = File(_getFilePath(widget.attachment));

    String tempFilename = _getExportFileName(widget.attachment);

    final tempDir = await getTemporaryDirectory();
    final tempPath = p.join(tempDir.path, tempFilename);

    await file.copy(tempPath);

    await SharePlus.instance.share(ShareParams(files: [XFile(tempPath)]));
  }

  List<AttachmentDto> get _mediaAttachments {
    if (!_isMediaAttachment(widget.attachment)) {
      return const [];
    }

    return (widget.mediaAttachments ?? [widget.attachment])
        .where(_isMediaAttachment)
        .toList();
  }

  List<AttachmentDto> _attachmentsToPrepare() {
    if (_isMediaAttachment(widget.attachment)) {
      return _mediaAttachments;
    }

    return [widget.attachment];
  }

  String _getFilePath([AttachmentDto? attachment]) {
    final targetAttachment = attachment ?? widget.attachment;
    return p.join(widget.data.tempDir.path, "media_${targetAttachment.id}");
  }

  String _getExtension([AttachmentDto? attachment]) {
    final targetAttachment = attachment ?? widget.attachment;

    if (targetAttachment.type == AttachmentType.photo) {
      return ".jpg";
    } else if (targetAttachment.type == AttachmentType.audio) {
      return ".mp3";
    } else {
      return p.extension(targetAttachment.uri);
    }
  }

  String _getExportFileName(AttachmentDto attachment) {
    final baseName = p.basenameWithoutExtension(attachment.uri).trim();
    final fallbackName =
        attachment.type == AttachmentType.video
            ? "video_${attachment.id}"
            : "photo_${attachment.id}";
    return "${baseName.isEmpty ? fallbackName : baseName}${_getExtension(attachment)}";
  }

  bool _isMediaAttachment(AttachmentDto attachment) {
    return attachment.type == AttachmentType.photo ||
        attachment.type == AttachmentType.video;
  }

  Future<void> _prepareFiles() async {
    final preparedIds = <int>{};

    for (final attachment in _attachmentsToPrepare()) {
      if (!preparedIds.add(attachment.id)) {
        continue;
      }

      await _prepareFile(attachment);

      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _prepareFile(AttachmentDto attachment) async {
    final file = File(_getFilePath(attachment));
    final exists = await file.exists();

    if (!exists || await file.length() == 0) {
      final remFile = ReminiscenceFile();
      remFile.pageHeaderCache = widget.data.file.pageHeaderCache;
      await remFile.open(widget.data.file.name);

      if (widget.data.secretKey == null) {
        await remFile.writeMediaToFile(attachment.id, file);
      } else {
        final stream = remFile.readMedia(attachment.id);
        await decryptStream(
          stream: stream,
          outputFile: file,
          secretKey: widget.data.secretKey!,
        );
      }

      await remFile.close();
    }
  }

  bool _sameAttachmentIds(
    List<AttachmentDto>? first,
    List<AttachmentDto>? second,
  ) {
    final firstIds = (first ?? const <AttachmentDto>[]).map((a) => a.id);
    final secondIds = (second ?? const <AttachmentDto>[]).map((a) => a.id);

    if (firstIds.length != secondIds.length) {
      return false;
    }

    for (final (index, id) in firstIds.indexed) {
      if (id != secondIds.elementAt(index)) {
        return false;
      }
    }

    return true;
  }
}
