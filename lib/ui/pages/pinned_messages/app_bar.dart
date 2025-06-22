import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final numPinned = Provider.of<List<MessageDto>>(context).length;

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      title: Text(
        "$numPinned Pinned Messages",
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      scrolledUnderElevation: 0.0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
