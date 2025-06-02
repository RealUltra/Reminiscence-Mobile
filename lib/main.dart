import 'package:flutter/material.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:reminiscence/ui/theme/app_theme.dart';
import 'package:reminiscence/ui/pages/data_loader/data_loader_page.dart';

final mediaStorePlugin = MediaStore();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MediaStore.ensureInitialized();

  List<Permission> permissions = [Permission.storage];
  if ((await mediaStorePlugin.getPlatformSDKInt()) >= 33) {
    permissions.add(Permission.photos);
    permissions.add(Permission.audio);
    permissions.add(Permission.videos);
  }
  await permissions.request();

  MediaStore.appFolder = "Reminiscence";

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Reminiscence",
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: "/",
      routes: {'/': (context) => DataLoaderPage(mediaStorePlugin)},
    );
  }
}
