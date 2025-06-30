import 'package:emoji_regex/emoji_regex.dart';
import 'package:stemmer/SnowballStemmer.dart';

SnowballStemmer stemmer = SnowballStemmer();

Set<String> tokenize(String text) {
  final words = text.split(" ").where((w) => w.isNotEmpty).toList();
  final emojis = emojiRegex().allMatches(text).map((e) => e[0]!).toList();

  final tokens = words.map((w) => stemmer.stem(w)).toList();
  tokens.addAll(emojis);

  return tokens.toSet();
}
