const magicNumber = "REM0";

const metadataPageId = 1;
const footerPageId = 2;

const pageSize = 4096;
const pageHeaderSize = 12;
final mediaIndexEntrySize = 8;

final maxPayloadSize = pageSize - pageHeaderSize;

int getPagePosition(int pageId) {
  return (pageId - 1) * pageSize + magicNumber.length;
}
