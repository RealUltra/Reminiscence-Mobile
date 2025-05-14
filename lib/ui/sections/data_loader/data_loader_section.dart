import 'package:flutter/material.dart';

import 'package:reminiscence/ui/sections/data_loader/app_bar.dart';
import 'package:reminiscence/ui/sections/data_loader/body.dart';

class DataLoaderSection extends StatelessWidget {
  const DataLoaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: MyAppBar(), body: Body());
  }
}
