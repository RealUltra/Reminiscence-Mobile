String formatNumber(int num) {
  List<String> chars = num.toString().split("").reversed.toList();
  for (int i = 3; i < chars.length; i += 4) {
    chars.insert(i, ",");
  }
  return chars.reversed.join("");
}
