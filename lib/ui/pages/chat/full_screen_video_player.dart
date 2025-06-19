import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback? onShare;

  const FullScreenVideoPlayer(this.controller, {super.key, this.onShare});

  @override
  State<FullScreenVideoPlayer> createState() => FullScreenVideoPlayerState();
}

class FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late final VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = widget.controller;
    controller.addListener(_updatePosition);
  }

  @override
  void dispose() {
    controller.removeListener(_updatePosition);
    super.dispose();
  }

  void _updatePosition() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Spacer(),
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
            Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                SliderTheme(
                  data: SliderThemeData(
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.0),
                  ),
                  child: Slider(
                    value: controller.value.position.inMilliseconds.toDouble(),
                    max: controller.value.duration.inMilliseconds.toDouble(),
                    onChanged: (double value) {
                      final newPosition = Duration(milliseconds: value.toInt());
                      controller.seekTo(newPosition);
                    },
                    padding: EdgeInsets.zero,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            controller.value.isPlaying ? _pause() : _play();
                          },
                          icon: Icon(
                            controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        ),
                        Text(
                          "${_formatDuration(controller.value.position)} / ${_formatDuration(controller.value.duration)}",
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        widget.onShare != null
                            ? IconButton(
                              onPressed: widget.onShare,
                              icon: Icon(Icons.share),
                            )
                            : Container(),

                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.fullscreen_exit),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _play() async {
    await controller.play();
    setState(() {});
  }

  Future<void> _pause() async {
    await controller.pause();
    setState(() {});
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
