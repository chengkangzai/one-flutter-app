import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/cache_manager.dart';

class CacheProvider extends ChangeNotifier {
  final CacheManager _cacheManager = CacheManager();

  int _cacheExpirationHours = CacheManager.defaultCacheExpirationHours;
  bool _offlineModeEnabled = CacheManager.defaultOfflineModeEnabled;
  int _maxCacheSizeMB = CacheManager.defaultMaxCacheSizeMB;
  double _currentCacheSizeMB = 0;
  bool _isLoading = true;

  CacheProvider() {
    _loadSettings();
  }

  // Getters
  int get cacheExpirationHours => _cacheExpirationHours;
  bool get offlineModeEnabled => _offlineModeEnabled;
  int get maxCacheSizeMB => _maxCacheSizeMB;
  double get currentCacheSizeMB => _currentCacheSizeMB;
  bool get isLoading => _isLoading;

  // Load settings from cache manager
  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cacheExpirationHours = await _cacheManager.getCacheExpirationHours();
      _offlineModeEnabled = await _cacheManager.getOfflineModeEnabled();
      _maxCacheSizeMB = await _cacheManager.getMaxCacheSizeMB();
      _currentCacheSizeMB = await _cacheManager.calculateCacheSizeMB();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading cache settings: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reload settings
  Future<void> refreshSettings() async {
    await _loadSettings();
  }

  // Update cache expiration hours
  Future<void> setCacheExpirationHours(int hours) async {
    try {
      await _cacheManager.setCacheExpirationHours(hours);
      _cacheExpirationHours = hours;
      notifyListeners();
    } catch (e) {
      print('Error updating cache expiration hours: $e');
    }
  }

  // Update offline mode
  Future<void> setOfflineModeEnabled(bool enabled) async {
    try {
      await _cacheManager.setOfflineModeEnabled(enabled);
      _offlineModeEnabled = enabled;
      notifyListeners();
    } catch (e) {
      print('Error updating offline mode: $e');
    }
  }

  // Update max cache size
  Future<void> setMaxCacheSizeMB(int sizeMB) async {
    try {
      await _cacheManager.setMaxCacheSizeMB(sizeMB);
      _maxCacheSizeMB = sizeMB;

      // Check if cache needs cleanup based on new size
      await _cacheManager.cleanupCacheIfNeeded();
      _currentCacheSizeMB = await _cacheManager.calculateCacheSizeMB();

      notifyListeners();
    } catch (e) {
      print('Error updating max cache size: $e');
    }
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    try {
      await _cacheManager.clearAllCache();
      _currentCacheSizeMB = await _cacheManager.calculateCacheSizeMB();
      notifyListeners();
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Get force refresh setting based on connectivity and offline mode
  Future<bool> shouldForceRefresh() async {
    // Note: You could integrate with a connectivity package here
    // to determine if the device is online or offline

    // For now, always force refresh if offline mode is disabled
    return !_offlineModeEnabled;
  }
}
