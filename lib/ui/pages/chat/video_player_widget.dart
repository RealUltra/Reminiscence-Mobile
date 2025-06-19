import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/chat/full_screen_video_player.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final File videoFile;
  final VoidCallback? onShare;

  const VideoPlayerWidget(this.videoFile, {super.key, this.onShare});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool isReady = false;
  late final VideoPlayerController controller;

  final controlsDisplayDuration = Duration(seconds: 5);

  bool showControls = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  Future<void> initVideo() async {
    controller = VideoPlayerController.file(widget.videoFile);
    controller.addListener(() => setState(() {}));
    await controller.initialize();

    setState(() {
      isReady = true;
    });
  }

  @override
  void dispose() {
    if (isReady) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return CircularProgressIndicator();
    }

    return GestureDetector(
      onTap: () => _toggleControls(),

      child: SizedBox(
        width: 300,
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),

            (showControls || !controller.value.isPlaying)
                ? Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,

                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 4.0,
                          ),
                        ),
                        child: Slider(
                          value:
                              controller.value.position.inMilliseconds
                                  .toDouble(),
                          max:
                              controller.value.duration.inMilliseconds
                                  .toDouble(),
                          onChanged: (double value) {
                            final newPosition = Duration(
                              milliseconds: value.toInt(),
                            );
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
                                  controller.value.isPlaying
                                      ? _pause()
                                      : _play();
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
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => FullScreenVideoPlayer(
                                            controller,
                                            onShare: widget.onShare,
                                          ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.fullscreen),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> _play() async {
    await controller.play();

    if (!showControls) {
      _toggleControls();
    }

    setState(() {});
  }

  Future<void> _pause() async {
    await controller.pause();
    setState(() {});
  }

  void _toggleControls() {
    if (showControls) {
      setState(() {
        showControls = false;
      });

      return;
    }

    setState(() {
      showControls = true;
    });

    _hideTimer?.cancel();

    _hideTimer = Timer(controlsDisplayDuration, () {
      setState(() {
        showControls = false;
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
