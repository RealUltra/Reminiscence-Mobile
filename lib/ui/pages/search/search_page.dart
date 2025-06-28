import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/search/app_bar.dart';
import 'package:reminiscence/ui/pages/search/body.dart';
import 'package:reminiscence/ui/pages/search/filter.dart';
import 'package:reminiscence/ui/pages/search/filter_controller.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  FilterController filterController = FilterController({});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(filterController: filterController),
      body: Body(),
    );
  }
}
