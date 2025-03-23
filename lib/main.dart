import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/cache_provider.dart';
import 'package:flutter_application_1/providers/favorites_provider.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:flutter_application_1/screens/cache_screen.dart';
import 'package:flutter_application_1/screens/favorites_page.dart';
import 'package:provider/provider.dart';
import 'screens/home_page.dart';
import 'screens/settings_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CacheProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current theme from the provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'ONE一个',
      // Use the theme provider to decide the theme
      themeMode: themeProvider.themeMode,
      // Light theme configuration
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: themeProvider.colorScheme,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        cardTheme: const CardTheme(color: Colors.white),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
        ),
      ),
      // Dark theme configuration
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: themeProvider.colorScheme,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1C1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: const CardTheme(color: Color(0xFF1D1D1D)),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1C1E),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        ),
      ),
      routes: {
        '/': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/settings/cache': (context) => const CacheSettingsScreen(),
        '/favorites': (context) => const FavoritesPage(),
      },
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
}
