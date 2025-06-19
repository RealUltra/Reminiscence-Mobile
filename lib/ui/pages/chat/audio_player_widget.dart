import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/chat/audio_manager.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioFilePath;

  const AudioPlayerWidget(this.audioFilePath, {super.key});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final audioPlayer = AudioPlayer();

  final double minPlaybackSpeed = 1.0;
  final double maxPlaybackSpeed = 2.0;
  final double playbackSpeedInterval = 0.5;

  late double playbackSpeed;
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    playbackSpeed = minPlaybackSpeed;

    initAudio();
  }

  Future<void> initAudio() async {
    await audioPlayer.setSource(DeviceFileSource(widget.audioFilePath));

    final duration = await audioPlayer.getDuration();

    if (duration != null && mounted) {
      setState(() {
        totalDuration = duration;
      });
    }

    audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          totalDuration = duration;
        });
      }
    });

    audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        currentPosition = p;
      });
    });

    audioPlayer.onPlayerComplete.listen((_) {
      if (isPlaying && mounted) {
        setState(() {
          isPlaying = false;
          currentPosition = Duration.zero;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => _toggleSpeed(),
                icon: Icon(
                  Icons.speed,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                label: Text(
                  "${playbackSpeed.toStringAsFixed(1)}x",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.download,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _stop(),
                    icon: Icon(
                      Icons.stop,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Divider(color: Theme.of(context).colorScheme.onSurfaceVariant),

          Row(
            children: [
              IconButton(
                onPressed: () async {
                  await (isPlaying ? _pause() : _play());
                },
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              Expanded(
                child: Slider(
                  value: currentPosition.inMilliseconds.toDouble(),
                  max: totalDuration.inMilliseconds.toDouble(),
                  activeColor: Theme.of(context).colorScheme.onSurface,
                  inactiveColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  onChanged: (double value) {
                    final newPosition = Duration(milliseconds: value.toInt());
                    audioPlayer.seek(newPosition);
                  },
                ),
              ),

              Text(
                _formatDuration(currentPosition),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                " / ${_formatDuration(totalDuration)}",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pause() async {
    await audioPlayer.pause();

    if (mounted) {
      setState(() {
        isPlaying = false;
      });
    }
  }

  Future<void> _play() async {
    AudioManager().play(audioPlayer, _pause);

    await audioPlayer.play(DeviceFileSource(widget.audioFilePath));

    audioPlayer.setPlaybackRate(playbackSpeed);

    if (mounted) {
      setState(() {
        isPlaying = true;
      });
    }
  }

  Future<void> _stop() async {
    await audioPlayer.stop();

    if (mounted) {
      setState(() {
        isPlaying = false;
        currentPosition = Duration.zero;
      });
    }
  }

  Future<void> _toggleSpeed() async {
    setState(() {
      playbackSpeed += playbackSpeedInterval;

      if (playbackSpeed > maxPlaybackSpeed) {
        playbackSpeed = minPlaybackSpeed;
      }
    });

    await audioPlayer.setPlaybackRate(playbackSpeed);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
