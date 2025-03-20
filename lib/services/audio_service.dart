// lib/services/audio_service.dart
import 'package:flutter_application_1/models/position_data.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:math';

class AudioService {
  AudioPlayer? _player;
  String? _currentUrl;
  final _playingState = BehaviorSubject<bool>.seeded(false);
  final _positionDataSubject = BehaviorSubject<PositionData>();

  Stream<bool> get playingStream => _playingState.stream;
  Stream<PositionData> get positionDataStream => _positionDataSubject.stream;

  void init() async {
    _player = AudioPlayer();

    // Configure the audio session
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Listen to player state changes
    _player!.playerStateStream.listen((state) {
      if (state.playing) {
        _playingState.add(true);
      } else {
        _playingState.add(false);
      }
    });

    // Listen to position changes
     Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      _player!.positionStream,
      _player!.bufferedPositionStream,
      _player!.durationStream,
      (position, bufferedPosition, duration) => PositionData(
        position,
        bufferedPosition,
        duration ?? Duration.zero,
      ),
    ).listen((positionData) {
      _positionDataSubject.add(positionData);
    });
  }

  Future<void> loadAudio(String url) async {
    if (_player == null) {
      init();
    }

    if (_currentUrl != url) {
      try {
        await _player!.stop();
        await _player!.setUrl(url);
        _currentUrl = url;
      } catch (e) {
        print("Error loading audio: $e");
      }
    }
  }

  Future<void> play() async {
    if (_player == null) return;

    try {
      await _player!.play();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  Future<void> pause() async {
    if (_player == null) return;

    try {
      await _player!.pause();
    } catch (e) {
      print("Error pausing audio: $e");
    }
  }

  Future<void> seek(Duration position) async {
    if (_player == null) return;

    try {
      await _player!.seek(position);
    } catch (e) {
      print("Error seeking audio: $e");
    }
  }

  Future<void> stop() async {
    if (_player == null) return;

    try {
      await _player!.stop();
    } catch (e) {
      print("Error stopping audio: $e");
    }
  }

  Future<void> dispose() async {
    if (_player == null) return;

    try {
      await _player!.dispose();
      _player = null;
      _currentUrl = null;
      _playingState.close();
      _positionDataSubject.close();
    } catch (e) {
      print("Error disposing audio player: $e");
    }
  }

  // Format duration in the form mm:ss
  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
