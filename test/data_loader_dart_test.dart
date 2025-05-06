import 'package:reminiscence/features/data_loader/data_loader.dart';

void main() async {
  final start = DateTime.now();
  final tempPath = await createRemFile(filePath);
  print("Duration: ${DateTime.now().difference(start).inMilliseconds}");

}