enum MessageColumn {
  id,
  chatId,
  idx,
  rawData,
  sentAt,
  senderName,
  content,
  noEmojisContent,
  attachmentId,
  attachmentType,
  attachmentUri,
}

final columnNameLookup = {
  MessageColumn.id: "m.id",
  MessageColumn.chatId: "m.chat_id",
  MessageColumn.rawData: "m.raw_data",
  MessageColumn.sentAt: "m.sent_at",
  MessageColumn.senderName: "m.sender_name",
  MessageColumn.content: "m.content",
  MessageColumn.noEmojisContent: "m.no_emojis_content",

  MessageColumn.attachmentId: "a.id as attachment_id",
  MessageColumn.attachmentType: "a.type as attachment_type",
  MessageColumn.attachmentUri: "a.uri as attachment_uri",
};

const allColumns = MessageColumn.values;

bool includesAttachment(List<MessageColumn> columns) {
  return columns.any(isAttachmentColumn);
}

bool isAttachmentColumn(MessageColumn column) {
  return column == MessageColumn.attachmentId ||
      column == MessageColumn.attachmentType ||
      column == MessageColumn.attachmentUri;
}

List<String> getColumnNames(List<MessageColumn> columns) {
  final columnNames = <String>[];

  for (final column in columns) {
    final columnName = columnNameLookup[column]!;
    columnNames.add(columnName);
  }

  return columnNames;
}
