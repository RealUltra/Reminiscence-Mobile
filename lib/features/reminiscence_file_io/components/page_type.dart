enum PageType { metadata, database, mediaIndex, media, free, footer }

final pageTypeValueMap = {
  PageType.metadata: 1,
  PageType.database: 2,
  PageType.mediaIndex: 3,
  PageType.media: 4,
  PageType.free: 5,
  PageType.footer: 6,
};

final pageTypeValueMapReversed = {
  for (var entry in pageTypeValueMap.entries) entry.value: entry.key,
};

int pageTypeToValue(PageType type) {
  return pageTypeValueMap[type]!;
}

PageType? valueToPageType(int value) {
  return pageTypeValueMapReversed[value];
}
