import "dart:convert";
import "dart:math";

List<int> generateNonce({int length = 16}) {
  final rand = Random.secure();
  return List<int>.generate(length, (_) => rand.nextInt(256));
}

String bytesToString(List<int> bytes) {
  return base64.encode(bytes);
}

List<int> stringToBytes(String string) {
  return base64.decode(string);
}
