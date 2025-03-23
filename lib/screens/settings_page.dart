import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/cache_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cacheProvider = Provider.of<CacheProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Cache settings section
          ListTile(
            title: const Text('Cache Settings'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Current usage: ${cacheProvider.currentCacheSizeMB.toStringAsFixed(2)} MB',
                  style: TextStyle(
                    color:
                        cacheProvider.currentCacheSizeMB >
                                cacheProvider.maxCacheSizeMB * 0.9
                            ? Colors.red
                            : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cacheProvider.offlineModeEnabled
                      ? 'Offline mode enabled'
                      : 'Offline mode disabled',
                ),
              ],
            ),
            leading: const Icon(Icons.storage),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/settings/cache');
            },
          ),

          const Divider(),

          // About section
          ListTile(
            title: const Text('About'),
            subtitle: const Text('ONE一个 App Version 1.0.0'),
            leading: const Icon(Icons.info_outline),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'ONE一个',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 ONE一个',
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'A Flutter application for ONE一个, bringing you daily content including articles, photos, and audio.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
