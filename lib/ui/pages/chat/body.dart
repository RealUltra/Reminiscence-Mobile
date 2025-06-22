import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/chat/messages_list.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: MessagesList(),
      ),
    );
  }
}
