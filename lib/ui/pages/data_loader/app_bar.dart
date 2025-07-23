import 'dart:io';

import 'package:flutter/material.dart';
import 'package:reminiscence/ui/components/video_player_widget.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Reminiscence"),

      scrolledUnderElevation: 0.0,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,

      actions: [
        IconButton(
          onPressed: () => showTutorial(context),
          icon: Icon(Icons.help_outline, size: 30),
        ),
      ],

      actionsPadding: EdgeInsets.only(right: 8),

      titleTextStyle: Theme.of(
        context,
      ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),

      titleSpacing: 24.0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  void showTutorial(BuildContext context) {
    /*
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => FullScreenAd(assetFilePath: "assets/tutorial-video.mp4"),
      ),
    );
    */

    showDialog(
      context: context,
      builder:
          (context) => Material(
            child: VideoPlayerWidget(
              File("assets/tutorial-video.mp4"),
              isAssetFile: true,
              allowFullScreen: false,
              startPlaying: true,
              alwaysShowControls: true,
            ),
          ),
    );
  }
}
