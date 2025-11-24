import 'package:flutter/material.dart';
import 'package:flashcards/screens/category_screen.dart';
import 'package:flashcards/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Lista ekranów dostępnych w dolnym pasku
  final List<Widget> _screens = [
    const CategoryScreen(), // Ekran główny z taliami
    const SettingsScreen(), // Ustawienia
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Tło aplikacji: Jasnoszare w dzień, ciemne w nocy (Standard branżowy)
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),

      body: _screens[_currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        indicatorColor: Colors.blueAccent.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style, color: Colors.blueAccent),
            label: 'Moje Talie',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: Colors.blueAccent),
            label: 'Ustawienia',
          ),
        ],
      ),
    );
  }
}