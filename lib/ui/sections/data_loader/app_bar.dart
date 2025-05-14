import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text("Reminiscence"));
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
