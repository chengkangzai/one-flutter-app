// lib/mixins/audio_screen_mixin.dart
import 'package:flutter/material.dart';

/// A mixin that helps manage audio lifecycle for screens containing audio players
mixin AudioScreenMixin<T extends StatefulWidget> on State<T> {
  // Flag to track if the screen is active
  bool _isScreenActive = true;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // When the screen becomes visible
    _isScreenActive = true;
  }
  
  @override
  void deactivate() {
    // When the screen is being navigated away from
    _isScreenActive = false;
    super.deactivate();
  }
  
  @override
  void dispose() {
    // Ensure we mark the screen as inactive when it's disposed
    _isScreenActive = false;
    super.dispose();
  }
  
  /// Check if it's safe to play audio on this screen
  bool get isScreenActive => _isScreenActive;
}