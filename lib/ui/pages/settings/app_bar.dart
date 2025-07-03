import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,

      title: Text(
        "Settings",
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),

      scrolledUnderElevation: 0.0,

      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => goBack(context),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  void goBack(BuildContext context) {
    final pageController = Provider.of<SelectionController<int>?>(
      context,
      listen: false,
    );

    if (pageController == null) {
      Navigator.of(context).pop();
      return;
    }

    pageController.selected = 0;
  }
}
