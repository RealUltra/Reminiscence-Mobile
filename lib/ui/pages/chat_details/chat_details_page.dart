import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/chat_details/app_bar.dart';
import 'package:reminiscence/ui/pages/chat_details/body.dart';

class ChatDetailsPage extends StatelessWidget {
  const ChatDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: MyAppBar(), body: Body());
  }
}
