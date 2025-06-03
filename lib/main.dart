import 'package:flutter/material.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:reminiscence/features/permissions_manager/permissions_manager.dart';

import 'package:reminiscence/ui/theme/app_theme.dart';
import 'package:reminiscence/ui/pages/data_loader/data_loader_page.dart';

final mediaStorePlugin = MediaStore();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MediaStore.ensureInitialized();

  await requestPermissions();

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
