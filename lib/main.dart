import 'package:flutter/material.dart';

import 'package:reminiscence/ui/theme/app_theme.dart';
import 'package:reminiscence/ui/pages/data_loader/data_loader_page.dart';

Future<void> main() async {
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
      routes: {'/': (context) => DataLoaderPage()},
    );
  }
}
