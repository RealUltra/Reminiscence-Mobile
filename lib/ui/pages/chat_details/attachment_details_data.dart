import 'package:reminiscence/features/database/dtos/attachment_dto.dart';

class AttachmentDetailsData {
  final AttachmentDto attachment;
  final String senderName;
  final DateTime sentAt;

  const AttachmentDetailsData({
    required this.attachment,
    required this.senderName,
    required this.sentAt,
  });
}
