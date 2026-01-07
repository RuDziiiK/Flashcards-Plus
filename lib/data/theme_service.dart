import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  // To jest nasz "nadajnik". Domyślnie ustawiony na false (jasny motyw)
  static final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  // Klucz do zapisu w pamięci
  static const String _key = 'is_dark_mode';

  // Funkcja zmieniająca motyw i zapisująca wybór
  static Future<void> toggleTheme(bool isDark) async {
    isDarkMode.value = isDark; // Zmień wartość w aplikacji
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark); // Zapisz w pamięci
  }

  // Funkcja wczytująca zapisany motyw przy starcie
  static Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    bool? savedTheme = prefs.getBool(_key);
    if (savedTheme != null) {
      isDarkMode.value = savedTheme;
    }
  }
}