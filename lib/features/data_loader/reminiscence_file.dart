import 'dart:io';

import 'package:reminiscence/features/database/database.dart';

class ReminiscenceFile {
  final AppDatabase db;
  final List<int> nonce;
  final Directory mediaDir;

  const ReminiscenceFile({
    required this.db,
    required this.nonce,
    required this.mediaDir,
  });
}
