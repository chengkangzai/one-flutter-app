import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class CacheManager {
  // Singleton instance
  static final CacheManager _instance = CacheManager._internal();

  // Factory constructor
  factory CacheManager() => _instance;

  // Private constructor
  CacheManager._internal();

  // Default cache settings
  static const int defaultCacheExpirationHours = 24;
  static const bool defaultOfflineModeEnabled = false;
  static const int defaultMaxCacheSizeMB = 100;

  // Get cache expiration hours
  Future<int> getCacheExpirationHours() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('cache_expiration_hours') ??
        defaultCacheExpirationHours;
  }

  // Set cache expiration hours
  Future<bool> setCacheExpirationHours(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt('cache_expiration_hours', hours);
  }

  // Get offline mode enabled
  Future<bool> getOfflineModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('offline_mode_enabled') ?? defaultOfflineModeEnabled;
  }

  // Set offline mode enabled
  Future<bool> setOfflineModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool('offline_mode_enabled', enabled);
  }

  // Get max cache size in MB
  Future<int> getMaxCacheSizeMB() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('max_cache_size_mb') ?? defaultMaxCacheSizeMB;
  }

  // Set max cache size in MB
  Future<bool> setMaxCacheSizeMB(int sizeMB) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt('max_cache_size_mb', sizeMB);
  }

  // Calculate current cache size in bytes
  Future<int> calculateCacheSize() async {
    try {
      int totalSize = 0;

      // Get shared preferences size
      final prefs = await SharedPreferences.getInstance();
      final prefsKeys = prefs.getKeys();
      for (final key in prefsKeys) {
        if (key.startsWith('essay_content_') ||
            key.startsWith('question_content_') ||
            key.startsWith('radio_content_') ||
            key.startsWith('one_data_') ||
            key.startsWith('related_articles_')) {
          // Approximate size of the cache entry
          final value = prefs.getString(key) ?? '';
          totalSize += value.length;
        }
      }

      // Get temporary directory size for audio files
      final tempDir = await getTemporaryDirectory();
      final dir = Directory(tempDir.path);
      await for (final file in dir.list(recursive: true)) {
        if (file is File && file.path.contains('audio_')) {
          final fileStat = await file.stat();
          totalSize += fileStat.size;
        }
      }

      return totalSize;
    } catch (e) {
      print('Error calculating cache size: $e');
      return 0;
    }
  }

  // Calculate current cache size in MB
  Future<double> calculateCacheSizeMB() async {
    final sizeInBytes = await calculateCacheSize();
    return sizeInBytes / (1024 * 1024); // Convert bytes to MB
  }

  // Clean up cache if over the limit
  Future<void> cleanupCacheIfNeeded() async {
    try {
      final maxSizeMB = await getMaxCacheSizeMB();
      final currentSizeMB = await calculateCacheSizeMB();

      if (currentSizeMB > maxSizeMB) {
        print(
          'Cache size ($currentSizeMB MB) exceeds limit ($maxSizeMB MB). Cleaning up...',
        );
        await cleanupCache();
      }
    } catch (e) {
      print('Error in cleanup check: $e');
    }
  }

  // Clean up cache based on last accessed time
  Future<void> cleanupCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsKeys = prefs.getKeys().toList();

      // Sort cache entries by timestamp (oldest first)
      final cacheEntries = <Map<String, dynamic>>[];

      for (final key in prefsKeys) {
        if (key.startsWith('essay_content_') ||
            key.startsWith('question_content_') ||
            key.startsWith('radio_content_') ||
            key.startsWith('one_data_') ||
            key.startsWith('related_articles_')) {
          final value = prefs.getString(key);
          if (value != null) {
            try {
              final decodedValue = json.decode(value);
              final timestamp = decodedValue['timestamp'] ?? 0;
              cacheEntries.add({
                'key': key,
                'timestamp': timestamp,
                'size': value.length,
              });
            } catch (e) {
              // Skip entries that can't be parsed
              print('Error parsing cache entry: $e');
            }
          }
        }
      }

      // Sort by timestamp (oldest first)
      cacheEntries.sort(
        (a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int),
      );

      // Delete oldest entries until we're under the limit
      final maxSizeBytes = (await getMaxCacheSizeMB()) * 1024 * 1024;
      int currentSize = await calculateCacheSize();

      for (final entry in cacheEntries) {
        if (currentSize <= maxSizeBytes * 0.8) {
          // Clear until we're at 80% of max
          break;
        }

        final key = entry['key'] as String;
        final size = entry['size'] as int;

        await prefs.remove(key);
        currentSize -= size;

        print('Removed cache entry: $key (${size / 1024} KB)');
      }

      // Clean up audio files (oldest first)
      if (currentSize > maxSizeBytes * 0.8) {
        final tempDir = await getTemporaryDirectory();
        final dir = Directory(tempDir.path);

        final audioFiles = <FileSystemEntity>[];
        await for (final file in dir.list(recursive: true)) {
          if (file is File && file.path.contains('audio_')) {
            audioFiles.add(file);
          }
        }

        // Sort by last modified time
        final fileModificationTimes = <File, DateTime>{};
        for (final file in audioFiles) {
          if (file is File) {
            final stat = await file.stat();
            fileModificationTimes[file] = stat.modified;
          }
        }

        audioFiles.sort((a, b) {
          final aTime = fileModificationTimes[a as File] ?? DateTime.now();
          final bTime = fileModificationTimes[b as File] ?? DateTime.now();
          return aTime.compareTo(bTime);
        });

        // Delete oldest files until we're under the limit
        for (final file in audioFiles) {
          if (currentSize <= maxSizeBytes * 0.8) {
            break;
          }

          if (file is File) {
            final size = (await file.stat()).size;
            await file.delete();
            currentSize -= size;

            print('Removed audio file: ${file.path} (${size / 1024} KB)');
          }
        }
      }

      print(
        'Cache cleanup complete. New size: ${await calculateCacheSizeMB()} MB',
      );
    } catch (e) {
      print('Error cleaning up cache: $e');
    }
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    try {
      // Clear SharedPreferences cache
      final prefs = await SharedPreferences.getInstance();
      final prefsKeys = prefs.getKeys().toList();

      for (final key in prefsKeys) {
        if (key.startsWith('essay_content_') ||
            key.startsWith('question_content_') ||
            key.startsWith('radio_content_') ||
            key.startsWith('one_data_') ||
            key.startsWith('related_articles_')) {
          await prefs.remove(key);
        }
      }

      // Clear audio files
      final tempDir = await getTemporaryDirectory();
      final dir = Directory(tempDir.path);

      await for (final file in dir.list(recursive: true)) {
        if (file is File && file.path.contains('audio_')) {
          await file.delete();
        }
      }

      print('All cache cleared successfully');
    } catch (e) {
      print('Error clearing all cache: $e');
    }
  }
}
