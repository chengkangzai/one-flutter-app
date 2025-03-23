import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/services/cache_manager.dart';

class CacheSettingsScreen extends StatefulWidget {
  const CacheSettingsScreen({Key? key}) : super(key: key);

  @override
  _CacheSettingsScreenState createState() => _CacheSettingsScreenState();
}

class _CacheSettingsScreenState extends State<CacheSettingsScreen> {
  final CacheManager _cacheManager = CacheManager();

  int _cacheExpirationHours = CacheManager.defaultCacheExpirationHours;
  bool _offlineModeEnabled = CacheManager.defaultOfflineModeEnabled;
  int _maxCacheSizeMB = CacheManager.defaultMaxCacheSizeMB;
  double _currentCacheSizeMB = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final expirationHours = await _cacheManager.getCacheExpirationHours();
      final offlineModeEnabled = await _cacheManager.getOfflineModeEnabled();
      final maxCacheSizeMB = await _cacheManager.getMaxCacheSizeMB();
      final currentCacheSizeMB = await _cacheManager.calculateCacheSizeMB();

      setState(() {
        _cacheExpirationHours = expirationHours;
        _offlineModeEnabled = offlineModeEnabled;
        _maxCacheSizeMB = maxCacheSizeMB;
        _currentCacheSizeMB = currentCacheSizeMB;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading cache settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final scaffold = ScaffoldMessenger.of(context);

    try {
      await _cacheManager.setCacheExpirationHours(_cacheExpirationHours);
      await _cacheManager.setOfflineModeEnabled(_offlineModeEnabled);
      await _cacheManager.setMaxCacheSizeMB(_maxCacheSizeMB);

      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      // Check if cache needs cleanup based on new settings
      await _cacheManager.cleanupCacheIfNeeded();

      // Reload current cache size
      final currentCacheSizeMB = await _cacheManager.calculateCacheSizeMB();
      setState(() {
        _currentCacheSizeMB = currentCacheSizeMB;
      });
    } catch (e) {
      print('Error saving cache settings: $e');
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _clearAllCache() async {
    final scaffold = ScaffoldMessenger.of(context);

    try {
      await _cacheManager.clearAllCache();

      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Cache cleared successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      // Reload current cache size
      final currentCacheSizeMB = await _cacheManager.calculateCacheSizeMB();
      setState(() {
        _currentCacheSizeMB = currentCacheSizeMB;
      });
    } catch (e) {
      print('Error clearing cache: $e');
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Error clearing cache: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cache Settings')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current cache usage
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cache Usage',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: _currentCacheSizeMB / _maxCacheSizeMB,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _currentCacheSizeMB > _maxCacheSizeMB * 0.9
                                    ? Colors.red
                                    : _currentCacheSizeMB >
                                        _maxCacheSizeMB * 0.7
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_currentCacheSizeMB.toStringAsFixed(2)} MB / $_maxCacheSizeMB MB',
                              style: TextStyle(
                                color:
                                    _currentCacheSizeMB > _maxCacheSizeMB * 0.9
                                        ? Colors.red
                                        : _currentCacheSizeMB >
                                            _maxCacheSizeMB * 0.7
                                        ? Colors.orange
                                        : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _clearAllCache,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Clear All Cache'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Cache expiration settings
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cache Settings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Cache expiration hours
                            const Text('Cache Expiration (hours)'),
                            TextField(
                              controller: TextEditingController(
                                text: _cacheExpirationHours.toString(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    _cacheExpirationHours = int.parse(value);
                                  });
                                }
                              },
                              decoration: const InputDecoration(
                                hintText: 'Enter hours',
                                suffixText: 'hours',
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Max cache size
                            const Text('Maximum Cache Size (MB)'),
                            TextField(
                              controller: TextEditingController(
                                text: _maxCacheSizeMB.toString(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    _maxCacheSizeMB = int.parse(value);
                                  });
                                }
                              },
                              decoration: const InputDecoration(
                                hintText: 'Enter size in MB',
                                suffixText: 'MB',
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Offline mode toggle
                            SwitchListTile(
                              title: const Text('Offline Mode'),
                              subtitle: const Text(
                                'Automatically cache content for offline viewing',
                              ),
                              value: _offlineModeEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _offlineModeEnabled = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveSettings,
                        child: const Text('Save Settings'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
