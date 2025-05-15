import 'package:flutter/material.dart';

import 'package:reminiscence/ui/pages/data_loader/data_loader_page.dart';
import 'package:reminiscence/ui/theme/app_theme.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Reminiscence",
      theme: AppTheme.dark,
      initialRoute: "/",
      routes: {'/': (context) => DataLoaderPage()},
    );
  }
}
