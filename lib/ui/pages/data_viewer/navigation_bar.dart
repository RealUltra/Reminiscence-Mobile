import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';

class MyNavigationBar extends StatefulWidget {
  final SelectionController<int> pageController;
  final bool messagesEnabled;

  const MyNavigationBar({
    super.key,
    required this.pageController,
    required this.messagesEnabled,
  });

  @override
  State<MyNavigationBar> createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (int index) {
        setState(() {
          widget.pageController.selected = index;
        });
      },

      indicatorColor: Theme.of(context).colorScheme.primaryContainer,

      selectedIndex: widget.pageController.selected,

      destinations: <Widget>[
        NavigationDestination(
          selectedIcon: Icon(Icons.home),
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),

        NavigationDestination(
          selectedIcon: Icon(Icons.messenger_sharp),
          icon: Icon(Icons.messenger_outline_sharp),
          label: 'Messages',
          enabled: widget.messagesEnabled,
        ),

        NavigationDestination(
          selectedIcon: Icon(Icons.settings),
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
    );
  }
}
