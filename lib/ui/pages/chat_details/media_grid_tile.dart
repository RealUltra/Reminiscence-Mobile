import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/attachment_dto.dart';
import 'package:reminiscence/features/database/tables/attachment_type.dart';
import 'package:reminiscence/features/encryption/encryption.dart';
import 'package:reminiscence/features/reminiscence_file_io/reminiscence_file.dart';
import 'package:reminiscence/ui/components/media_widget.dart';
import 'package:reminiscence/ui/pages/chat_details/attachment_details_data.dart';

class MediaGridTile extends StatefulWidget {
  final AttachmentDetailsData attachment;
  final List<AttachmentDetailsData> allAttachments;
  final int index;
  final ReminiscenceData data;

  const MediaGridTile({
    super.key,
    required this.attachment,
    required this.allAttachments,
    required this.index,
    required this.data,
  });

  @override
  State<MediaGridTile> createState() => MediaGridTileState();
}

class MediaGridTileState extends State<MediaGridTile> {
  @override
  void initState() {
    super.initState();

    _prepareFile(widget.attachment.attachment);
  }

  @override
  void didUpdateWidget(covariant MediaGridTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.attachment.attachment.id != widget.attachment.attachment.id) {
      _prepareFile(widget.attachment.attachment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _getMediaItem(widget.attachment.attachment);

    return AspectRatio(
      aspectRatio: 1.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.0),
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: InkWell(
            onTap: item.isReady ? _openViewer : null,
            child:
                item.isReady
                    ? _buildPreview(item)
                    : Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(MediaAttachmentItem item) {
    if (item.isVideo) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          Center(
            child: Icon(Icons.play_circle, color: Colors.white, size: 36.0),
          ),
        ],
      );
    }

    return Image.file(
      item.file,
      fit: BoxFit.cover,
      errorBuilder: (context, _, _) => const Icon(Icons.broken_image),
    );
  }

  Future<void> _openViewer() async {
    await openMediaViewer(context, _getMediaItems(), widget.index);
  }

  List<MediaAttachmentItem> _getMediaItems() {
    return widget.allAttachments.map((attachment) {
      return _getMediaItem(attachment.attachment);
    }).toList();
  }

  MediaAttachmentItem _getMediaItem(AttachmentDto attachment) {
    return MediaAttachmentItem(
      type:
          attachment.type == AttachmentType.photo
              ? MediaAttachmentType.photo
              : MediaAttachmentType.video,
      file: File(_getFilePath(attachment)),
      fileName: _getExportFileName(attachment),
      mimeType:
          attachment.type == AttachmentType.photo ? "image/jpeg" : "video/mp4",
      prepare: () => _prepareFile(attachment),
    );
  }

  String _getFilePath(AttachmentDto attachment) {
    return p.join(widget.data.tempDir.path, "media_${attachment.id}");
  }

  String _getExtension(AttachmentDto attachment) {
    if (attachment.type == AttachmentType.photo) {
      return ".jpg";
    }

    return p.extension(attachment.uri);
  }

  String _getExportFileName(AttachmentDto attachment) {
    final baseName = p.basenameWithoutExtension(attachment.uri).trim();
    final fallbackName =
        attachment.type == AttachmentType.video
            ? "video_${attachment.id}"
            : "photo_${attachment.id}";

    return "${baseName.isEmpty ? fallbackName : baseName}${_getExtension(attachment)}";
  }

  Future<void> _prepareFile(AttachmentDto attachment) async {
    final file = File(_getFilePath(attachment));
    final exists = await file.exists();

    if (exists && await file.length() > 0) {
      return;
    }

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

    if (mounted) {
      setState(() {});
    }
  }
}
