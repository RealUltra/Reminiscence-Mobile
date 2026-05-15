import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/updates_and_review/app_updates.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';

import 'package:reminiscence/ui/pages/data_loader/app_bar.dart';
import 'package:reminiscence/ui/pages/data_loader/body.dart';
import 'package:reminiscence/ui/pages/data_loader/navigation_bar.dart';

import 'package:reminiscence/ui/pages/settings/app_bar.dart' as settings_page;
import 'package:reminiscence/ui/pages/settings/body.dart' as settings_page;

class DataLoaderPage extends StatefulWidget {
  const DataLoaderPage({super.key});

  @override
  State<DataLoaderPage> createState() => _DataLoaderPageState();
}

class _DataLoaderPageState extends State<DataLoaderPage> {
  final pageController = SelectionController<int>(0);

  final appBars = <PreferredSizeWidget>[MyAppBar(), settings_page.MyAppBar()];
  final bodies = <Widget>[Body(), settings_page.Body()];

  @override
  void initState() {
    super.initState();

    pageController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      checkForFlexibleUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SelectionController<int>>.value(value: pageController),
      ],

      child: Scaffold(
        appBar: appBars[pageController.selected],
        body: IndexedStack(index: pageController.selected, children: bodies),
        bottomNavigationBar: MyNavigationBar(pageController: pageController),
      ),
    );
  }
}
