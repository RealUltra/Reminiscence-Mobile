import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/chats_list/utils.dart';

class MyAppBar extends StatelessWidget {
  final int numChats;

  const MyAppBar({super.key, required this.numChats});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "${formatNumber(numChats)} Chats Loaded",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // Handle Settings
          },
        ),
      ],
    );
  }
}
