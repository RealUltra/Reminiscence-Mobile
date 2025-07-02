import 'package:flutter/material.dart';

class TitleCard extends StatelessWidget {
  const TitleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.settings_suggest),
      title: Text("System Messages"),
      subtitle: Text("Tap any to unmark as system message."),
    );
  }
}
