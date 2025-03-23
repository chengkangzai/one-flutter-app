import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  // Cache expiration time (in hours)
  final int _cacheExpirationHours;

  // Constructor with default expiration of 24 hours
  CacheService({int cacheExpirationHours = 24})
    : _cacheExpirationHours = cacheExpirationHours;

  // Save JSON data to cache
  Future<bool> cacheData(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Create cache entry with data and timestamp
      final cacheEntry = {'data': data, 'timestamp': timestamp};

      // Save as JSON string
      final jsonString = json.encode(cacheEntry);
      return await prefs.setString(key, jsonString);
    } catch (e) {
      print('Error caching data: $e');
      return false;
    }
  }

  // Get cached JSON data if still valid
  Future<dynamic> getCachedData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(key);

      if (cachedJson == null) {
        return null;
      }

      final cacheEntry = json.decode(cachedJson);
      final timestamp = cacheEntry['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      // Check if cache has expired
      if (now.difference(cacheTime).inHours > _cacheExpirationHours) {
        return null;
      }

      return cacheEntry['data'];
    } catch (e) {
      print('Error retrieving cached data: $e');
      return null;
    }
  }

  // Clear specific cached data
  Future<bool> clearCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(key);
    } catch (e) {
      print('Error clearing cache: $e');
      return false;
    }
  }

  // Clear all cached data
  Future<bool> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    } catch (e) {
      print('Error clearing all cache: $e');
      return false;
    }
  }

  // Cache audio file
  Future<String?> cacheAudioFile(String url, String filename) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);

      // Check if file already exists
      if (await file.exists()) {
        return filePath;
      }

      // Download and save file
      final response = await HttpClient().getUrl(Uri.parse(url));
      final httpResponse = await response.close();

      if (httpResponse.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(httpResponse);
        await file.writeAsBytes(bytes);
        return filePath;
      } else {
        print('Error downloading audio file: ${httpResponse.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error caching audio file: $e');
      return null;
    }
  }

  // Get cached audio file path
  Future<String?> getCachedAudioFile(String filename) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);

      if (await file.exists()) {
        return filePath;
      }

      return null;
    } catch (e) {
      print('Error getting cached audio file: $e');
      return null;
    }
  }

  // Helper function to consolidate HTTP response bytes
  Future<List<int>> consolidateHttpClientResponseBytes(
    HttpClientResponse response,
  ) async {
    final List<List<int>> chunks = [];
    final List<int> contentLength = [0];

    await response.forEach((List<int> chunk) {
      chunks.add(chunk);
      contentLength[0] += chunk.length;
    });

    if (chunks.length == 1) {
      return chunks.first;
    }

    final Uint8List result = Uint8List(contentLength[0]);
    int offset = 0;
    for (final List<int> chunk in chunks) {
      result.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }

    return result;
  }
}
