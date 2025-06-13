import 'package:reminiscence/features/database/models/attachment_type.dart';

class AttachmentDto {
  final int id;
  final String messageId;
  late final AttachmentType type;
  final String uri;

  AttachmentDto({
    required this.id,
    required this.messageId,
    required String type,
    required this.uri,
  }) {
    this.type = AttachmentType.values.firstWhere(
      (v) => v.toString().split(".").last == type,
    );
  }
}
