// lib/widgets/audio_player_widget.dart
import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final String title;
  final String subtitle;

  const AudioPlayerWidget({
    Key? key,
    required this.audioUrl,
    required this.title,
    this.subtitle = '',
  }) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioService _audioService = AudioService();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _bufferedPosition = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    if (widget.audioUrl.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Audio URL is empty';
      });
      return;
    }

    try {
      _audioService.init();
      await _audioService.loadAudio(widget.audioUrl);
      _setupAudioListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  void _setupAudioListeners() {
    _audioService.playingStream.listen((playing) {
      if (mounted) {
        setState(() {
          _isPlaying = playing;
        });
      }
    });

    _audioService.positionDataStream.listen((positionData) {
      if (mounted) {
        setState(() {
          _position = positionData.position;
          _bufferedPosition = positionData.bufferedPosition;
          _duration = positionData.duration;
          _isLoading = false;
        });
      }
    });
  }
  
  void _handleError(dynamic e) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (e.toString().contains('Cleartext HTTP traffic not permitted')) {
          _errorMessage = 'HTTP traffic is blocked. Please check network_security_config.xml.';
        } else {
          _errorMessage = 'Failed to load audio: ${e.toString().split('\n')[0]}';
        }
      });
    }
    print("Error initializing audio: $e");
  }

  void _playPause() {
    if (_isPlaying) {
      _audioService.pause();
    } else {
      _audioService.play();
    }
  }

  void _seekToPosition(double value) {
    final position = Duration(milliseconds: value.round());
    _audioService.seek(position);
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and subtitle
          Text(
            widget.title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (widget.subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                widget.subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          const SizedBox(height: 16),

          // Audio URL for debugging
          if (_errorMessage.isNotEmpty && widget.audioUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Source: ${widget.audioUrl}',
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Loading indicator or error message
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else if (_errorMessage.isNotEmpty)
            Center(
              child: Column(
                children: [
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  if (_errorMessage.contains('Network security'))
                    TextButton(
                      onPressed: () => _initAudio(),
                      child: Text('Retry'),
                    ),
                ],
              ),
            )
          else if (widget.audioUrl.isEmpty)
            Center(child: Text('Audio not available'))
          else
            Column(
              children: [
                // Progress bar
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                  ),
                  child: Slider(
                    min: 0,
                    max: _duration.inMilliseconds > 0 
                        ? _duration.inMilliseconds.toDouble() 
                        : 1.0,
                    value: _position.inMilliseconds > _duration.inMilliseconds
                        ? _duration.inMilliseconds.toDouble()
                        : _position.inMilliseconds.toDouble(),
                    onChanged: _duration.inMilliseconds > 0
                        ? _seekToPosition
                        : null,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey[300],
                  ),
                ),

                // Position and duration display
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _audioService.formatDuration(_position),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _audioService.formatDuration(_duration),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      onPressed: _duration.inMilliseconds > 0
                          ? () => _audioService.seek(
                                _position - Duration(seconds: 10),
                              )
                          : null,
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      icon: Icon(
                        _isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 48,
                      ),
                      onPressed: _duration.inMilliseconds > 0
                          ? _playPause
                          : null,
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.forward_10),
                      onPressed: _duration.inMilliseconds > 0
                          ? () => _audioService.seek(
                                _position + Duration(seconds: 10),
                              )
                          : null,
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}