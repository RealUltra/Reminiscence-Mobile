import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenAd extends StatefulWidget {
  final String assetFilePath;

  const FullScreenAd({super.key, required this.assetFilePath});

  @override
  State<FullScreenAd> createState() => _FullScreenAdState();
}

class _FullScreenAdState extends State<FullScreenAd> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.assetFilePath)
      ..initialize().then((_) {
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child:
                  _controller.value.isInitialized
                      ? VideoPlayer(_controller)
                      : Container(),
            ),

            Positioned(
              top: 8,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(128),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
