import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _effectPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _volume = 0.7;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get volume => _volume;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _musicPlayer.stop();
    }
  }

  void setVolume(double volume) {
    _volume = volume;
    _effectPlayer.setVolume(volume);
    _musicPlayer.setVolume(volume * 0.3);
  }

  Future<void> playMove() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.play(AssetSource('sounds/move.mp3'));
    } catch (e) {
      // Fallback: no sound
    }
  }

  Future<void> playCapture() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.play(AssetSource('sounds/capture.mp3'));
    } catch (e) {
      // Fallback: no sound
    }
  }

  Future<void> playCheck() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.play(AssetSource('sounds/check.mp3'));
    } catch (e) {
      // Fallback: no sound
    }
  }

  Future<void> playCheckmate() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.play(AssetSource('sounds/checkmate.mp3'));
    } catch (e) {
      // Fallback: no sound
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.play(
        AssetSource('music/background.mp3'),
        volume: _volume * 0.3,
      );
      _musicPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      // Fallback: no music
    }
  }

  void stopMusic() {
    _musicPlayer.stop();
  }

  void dispose() {
    _effectPlayer.dispose();
    _musicPlayer.dispose();
  }
}