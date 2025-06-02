import 'package:flutter/material.dart';
import 'package:media_store_plus/media_store_plus.dart';

import 'package:reminiscence/ui/pages/data_loader/app_bar.dart';
import 'package:reminiscence/ui/pages/data_loader/body.dart';

class DataLoaderPage extends StatelessWidget {
  final MediaStore mediaStorePlugin;

  const DataLoaderPage(this.mediaStorePlugin, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: MyAppBar(), body: Body(mediaStorePlugin));
  }
}
