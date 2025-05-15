import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Reminiscence"),
      scrolledUnderElevation: 0.0,
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(onPressed: () {}, icon: Icon(Icons.help_outline, size: 30)),
      ],
      actionsPadding: EdgeInsets.only(right: 16),
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      titleSpacing: 18.0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
