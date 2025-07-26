import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/info_box.dart';

const longBoilerplateText = '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec commodo, sapien nec dignissim sagittis, libero neque fermentum elit, non eleifend nunc augue ut lorem. Aenean ut purus in nulla malesuada porta a vel felis. Nullam euismod sapien vitae tortor imperdiet, eget aliquam justo iaculis. Suspendisse vel finibus sem. In quis ex nec metus bibendum dictum. Cras accumsan blandit metus ac tincidunt. Sed porttitor arcu ac metus sodales, a ullamcorper sem rutrum. Integer non orci et quam porta feugiat. 

Aliquam erat volutpat. Duis nec neque vitae tortor pretium sodales. Aenean efficitur libero quis risus vestibulum, nec ultrices sem porttitor. Sed ultricies sapien non sagittis lacinia. Morbi a sem vel sapien pretium fermentum ut et lectus. Integer fringilla feugiat nulla, id luctus sem mattis eget. Ut ac sapien id elit mattis vestibulum. Morbi sit amet neque at augue efficitur volutpat.

Donec vulputate odio id lacus tincidunt feugiat. Sed eget justo ligula. Suspendisse potenti. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Nulla facilisi. Sed dignissim, ligula in convallis lobortis, erat libero consectetur libero, in luctus turpis libero nec tellus. Ut vel rutrum diam. Donec vel metus at lorem luctus porta. Pellentesque tristique lorem eget sem gravida, eget lacinia tortor volutpat.
''';

const shortBoilerplateText =
    "Your recent behavior has violated the standards for appropriate communications. Please refrain from this behavior or your ability to communicate will be restricted, you will lose access to competitive play, and you may lose access to the VALORANT Public Beta Environment (PBE).";

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),
      ),

      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: () => openInfoBox(context),
              child: Text("Click here for info box"),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openInfoBox(BuildContext context) async {
    await showDialog(
      context: context,
      builder:
          (context) =>
          InfoBox(title: "Terms Of Service", body: longBoilerplateText),
    );

    await showDialog(
      context: context,
      builder:
          (context) =>
          InfoBox(
            title: "Behavior Warning",
            body: shortBoilerplateText,
            actions: [
              InfoBoxButton(
                "I Understand",
                highlighted: true,
                value: 0,
              ),
              InfoBoxButton("Learn More", highlighted: false, value: 1),
            ],
          ),
    );
  }
}
