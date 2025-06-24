import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/ui/pages/chat/app_bar.dart';
import 'package:reminiscence/ui/pages/chat/body.dart';

class ChatPage extends StatelessWidget {
  final String? initialMessageId;
  final bool disabled;

  const ChatPage({
    super.key,
    required this.initialMessageId,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<String?>.value(value: initialMessageId),
        Provider<bool>.value(value: disabled),
      ],

      child: Scaffold(appBar: MyAppBar(), body: Body()),
    );
  }
}
