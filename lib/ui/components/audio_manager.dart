import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final _instance = AudioManager._internal();

  AudioPlayer? currentAudioPlayer;
  VoidCallback? pause;

  AudioManager._internal();

  factory AudioManager() => _instance;

  void play(AudioPlayer audioPlayer, VoidCallback pause) {
    if (currentAudioPlayer != audioPlayer) {
      stopCurrent();
    }

    currentAudioPlayer = audioPlayer;
    this.pause = pause;
  }

  void stopCurrent() {
    if (pause != null) {
      pause!();
      pause = null;
    }
  }
}
