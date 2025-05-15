import 'package:flutter/material.dart';

import 'package:reminiscence/ui/pages/data_loader/app_bar.dart';
import 'package:reminiscence/ui/pages/data_loader/body.dart';

class DataLoaderPage extends StatelessWidget {
  const DataLoaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: MyAppBar(), body: Body());
  }
}
