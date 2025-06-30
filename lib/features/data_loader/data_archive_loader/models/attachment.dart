import 'package:reminiscence/features/database/tables/attachment_type.dart';

class Attachment {
  final AttachmentType type;
  final String uri;

  Attachment({required this.type, required this.uri});
}
