import 'package:flutter/material.dart';
import 'package:flashcards/data/theme_service.dart'; // Upewnij się, że import działa

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  // Funkcja do resetowania (bez zmian)
  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Resetuj postępy"),
        content: const Text("Czy na pewno chcesz usunąć wszystkie postępy?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Anuluj"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Postępy zresetowane (demo).")),
              );
            },
            child: const Text("Resetuj", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("O aplikacji"),
        content: const Text("Fiszki Plus v1.0"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. SPRAWDZAMY AKTUALNY TRYB
    // Używamy ThemeService, aby wiedzieć, jaki jest stan
    bool isDark = ThemeService.isDarkMode.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ustawienia"),
      ),
      body: Container(
        // 2. DYNAMICZNY GRADIENT (To naprawia Twój problem!)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2C3E50), const Color(0xFF000000)] // Ciemne kolory dla trybu ciemnego
                : [Colors.blueAccent, Colors.lightBlueAccent],       // Niebieskie dla jasnego
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          children: [
            const SizedBox(height: 10),

            // --- Przełącznik Trybu Ciemnego ---
            Card(
              color: isDark ? Colors.grey[800] : Colors.white.withOpacity(0.9),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SwitchListTile(
                title: Text(
                  "Tryb ciemny",
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold
                  ),
                ),
                secondary: Icon(
                    Icons.dark_mode,
                    color: isDark ? Colors.amber : Colors.grey
                ),
                value: isDark,
                activeColor: Colors.indigoAccent,
                onChanged: (bool value) async {
                  // 3. ZMIANA STANU
                  await ThemeService.toggleTheme(value);
                  // 4. WAŻNE: Odświeżamy widok, żeby gradient się zmienił natychmiast
                  setState(() {});
                },
              ),
            ),

            // --- Powiadomienia ---
            Card(
              color: isDark ? Colors.grey[800] : Colors.white.withOpacity(0.9),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SwitchListTile(
                title: Text("Powiadomienia", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                secondary: Icon(Icons.notifications, color: isDark ? Colors.white70 : Colors.grey),
                value: _notificationsEnabled,
                activeColor: Colors.indigoAccent,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ),

            // --- Reset ---
            Card(
              color: isDark ? Colors.grey[800] : Colors.white.withOpacity(0.9),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text("Resetuj postępy", style: TextStyle(color: Colors.red)),
                onTap: _showResetConfirmation,
              ),
            ),

            // --- O aplikacji ---
            Card(
              color: isDark ? Colors.grey[800] : Colors.white.withOpacity(0.9),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Icon(Icons.info_outline, color: isDark ? Colors.white70 : Colors.grey),
                title: Text("O aplikacji", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                onTap: _showAboutApp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}