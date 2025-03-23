import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/position_data.dart';
import 'package:flutter_application_1/services/audio_service.dart';

class AudioPlayerWidget extends StatelessWidget {
  final AudioService audioService;

  const AudioPlayerWidget({super.key, required this.audioService});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Play/Pause button and current position
            StreamBuilder<bool>(
              stream: audioService.playingStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 64,
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: isPlaying ? audioService.pause : audioService.play,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            
            // Progress bar
            StreamBuilder<PositionData>(
              stream: audioService.positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data ??
                    PositionData(
                      const Duration(seconds: 0),
                      const Duration(seconds: 0),
                      const Duration(seconds: 0),
                    );
                
                return Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                      ),
                      child: Slider(
                        min: 0.0,
                        max: positionData.duration.inMilliseconds.toDouble(),
                        value: positionData.position.inMilliseconds.toDouble().clamp(
                          0,
                          positionData.duration.inMilliseconds.toDouble(),
                        ),
                        onChanged: (value) {
                          audioService.seek(
                            Duration(milliseconds: value.round()),
                          );
                        },
                      ),
                    ),
                    
                    // Position and duration labels
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(audioService.formatDuration(positionData.position)),
                          Text(audioService.formatDuration(positionData.duration)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}