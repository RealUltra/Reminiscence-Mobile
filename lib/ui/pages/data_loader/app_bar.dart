import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/full_screen_ad.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Reminiscence"),
      scrolledUnderElevation: 0.0,
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          onPressed: () => showTutorial(context),
          icon: Icon(Icons.help_outline, size: 30),
        ),
      ],
      actionsPadding: EdgeInsets.only(right: 16),
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      titleSpacing: 18.0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  void showTutorial(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => FullScreenAd(assetFilePath: "assets/tutorial-video.mp4"),
      ),
    );
  }
}
