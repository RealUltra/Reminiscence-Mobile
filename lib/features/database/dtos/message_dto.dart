import 'package:reminiscence/features/database/dtos/attachment_dto.dart';

class MessageDto {
  final String id;
  final int chatId;
  final int index;
  final String rawData;
  final int sentAt;
  final String senderName;
  final String content;
  final List<AttachmentDto> attachments;

  MessageDto({
    required this.id,
    required this.chatId,
    required this.index,
    required this.rawData,
    required this.sentAt,
    required this.senderName,
    required this.content,
    this.attachments = const [],
  });
}
