import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  List<Permission> permissions = [Permission.storage];
  await permissions.request();
}
