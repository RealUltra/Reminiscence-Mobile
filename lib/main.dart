import 'package:flutter/material.dart';

import 'package:reminiscence/ui/sections/data_loader/data_loader_section.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Reminiscence",
      theme: ThemeData(),
      initialRoute: "/",
      routes: {'/': (context) => DataLoaderSection()},
    );
  }
}
