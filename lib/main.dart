import 'package:flutter/material.dart';
import 'package:flashcards/screens/splash_screen.dart';
import 'package:flashcards/data/theme_service.dart';
import 'package:flashcards/data/notification_service.dart'; // Import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.loadThemePreference();
  // Inicjalizacja Awesome Notifications
  await NotificationService.init();
  runApp(const FlashcardsApp());
}

class FlashcardsApp extends StatelessWidget {
  const FlashcardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.isDarkMode,
      builder: (context, isDark, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flashcards Plus',

          // --- MOTYW JASNY ---
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              centerTitle: true,
            ),
          ),

          // --- MOTYW CIEMNY ---
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              foregroundColor: Colors.white,
              centerTitle: true,
            ),
            // USUNĄŁEM: cardTheme - Material 3 sam zadba o kolory kart
          ),

          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

          home: const SplashScreen(),
        );
      },
    );
  }
}