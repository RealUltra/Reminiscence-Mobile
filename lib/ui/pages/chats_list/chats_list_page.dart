import 'package:flutter/material.dart';

import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/ui/pages/chats_list/body.dart';

class ChatsListPage extends StatelessWidget {
  final ReminiscenceData data;

  const ChatsListPage(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Body(data));
  }
}
