import 'package:reminiscence/features/database/models/attachment_type.dart';
import 'package:reminiscence/ui/pages/search/filter_type.dart';

class Filter {
  final FilterType type;
  final dynamic value;

  const Filter({required this.type, required this.value});

  String? get query {
    if (type == FilterType.query) {
      return value as String;
    }

    return null;
  }

  String? get senderName {
    if (type == FilterType.sender) {
      return value as String;
    }

    return null;
  }

  AttachmentType? get attachmentType {
    if (type == FilterType.attachment) {
      return value as AttachmentType;
    }

    return null;
  }

  DateTime? get date {
    if (type == FilterType.sentBefore ||
        type == FilterType.sentOn ||
        type == FilterType.sentAfter) {
      return value as DateTime;
    }

    return null;
  }
}
