// lib/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/cache_provider.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cacheProvider = Provider.of<CacheProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          // Theme settings section
          ListTile(
            title: const Text('主题设置'),
            subtitle: Text(themeProvider.isDarkMode ? '深色模式' : '浅色模式'),
            leading: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.setDarkMode(value);
              },
            ),
          ),

          const Divider(),

          // Cache settings section
          ListTile(
            title: const Text('缓存设置'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '当前用量: ${cacheProvider.currentCacheSizeMB.toStringAsFixed(2)} MB',
                  style: TextStyle(
                    color:
                        cacheProvider.currentCacheSizeMB >
                                cacheProvider.maxCacheSizeMB * 0.9
                            ? Colors.red
                            : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(cacheProvider.offlineModeEnabled ? '离线模式已启用' : '离线模式已禁用'),
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
            title: const Text('关于'),
            subtitle: const Text('ONE一个 App 版本 1.0.0'),
            leading: const Icon(Icons.info_outline),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'ONE一个',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 ONE一个',
                children: [
                  const SizedBox(height: 16),
                  const Text('ONE一个是一款提供每日文章、照片和音频内容的应用程序。'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
