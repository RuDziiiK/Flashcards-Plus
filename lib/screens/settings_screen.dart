import 'package:flutter/material.dart';
import 'package:flashcards/data/theme_service.dart';
import 'package:flashcards/data/storage_service.dart';
import 'package:flashcards/data/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ekran ustawień aplikacji.
/// Umożliwia użytkownikowi konfigurację kluczowych aspektów działania aplikacji:
/// 1. Zmiana motywu graficznego (Jasny / Ciemny).
/// 2. Włączanie/wyłączanie codziennych powiadomień.
/// 3. Resetowanie wszystkich postępów i danych (strefa niebezpieczna).
/// 4. Wyświetlanie informacji o autorach projektu.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// Przechowuje lokalny stan przełącznika powiadomień.
  /// Jest synchronizowany z SharedPreferences przy starcie ekranu.
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    // Inicjalizacja: Wczytujemy zapisane ustawienia z pamięci urządzenia
    _loadSettings();
  }

  /// Asynchronicznie pobiera zapisany stan powiadomień.
  /// Dzięki temu, jeśli użytkownik włączył powiadomienia wcześniej,
  /// przełącznik będzie ustawiony w pozycji "włączone" po ponownym uruchomieniu.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Jeśli klucz nie istnieje (pierwsze uruchomienie), przyjmujemy false.
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    });
  }

  /// Wyświetla modalne okno dialogowe z prośbą o potwierdzenie resetu.
  /// Jest to operacja nieodwracalna, dlatego wymaga wyraźnej akcji użytkownika.
  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Resetuj wszystkie dane"),
        content: const Text(
            "To usunie:\n"
                "• Wszystkie Twoje talie i fiszki\n"
                "• Twój poziom i dni z rzędu (Streak)\n"
                "• Ustawienia powiadomień\n\n"
                "Tej operacji nie można cofnąć."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Anuluj"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // 1. Fizyczne usunięcie danych z pamięci trwałej
              await StorageService.clearAllData();

              // 2. Odwołanie wszystkich zaplanowanych w systemie powiadomień
              await NotificationService.cancelNotifications();

              // 3. Aktualizacja stanu UI (wyłączamy przełącznik powiadomień)
              setState(() {
                _notificationsEnabled = false;
              });

              if (mounted) {
                Navigator.pop(context); // Zamknięcie dialogu

                // 4. Wyświetlenie potwierdzenia (SnackBar)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Aplikacja została zresetowana do stanu początkowego."),
                    backgroundColor: Colors.redAccent,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text("Resetuj wszystko"),
          ),
        ],
      ),
    );
  }

  /// Obsługuje logikę przełączania powiadomień.
  /// [value] - nowy stan przełącznika (true/false).
  void _toggleNotifications(bool value) async {
    // 1. Natychmiastowa aktualizacja UI dla płynności
    setState(() {
      _notificationsEnabled = value;
    });

    // 2. Trwały zapis preferencji użytkownika
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);

    if (value) {
      // SCENARIUSZ WŁĄCZANIA:
      // Najpierw musimy upewnić się, że mamy uprawnienia systemowe (Android 13+)
      bool allowed = await NotificationService.requestPermissions();

      if (allowed) {
        // Jeśli jest zgoda -> planujemy cykliczne powiadomienie
        await NotificationService.scheduleDailyNotification();
        // Oraz wysyłamy testowe powiadomienie natychmiastowe
        await NotificationService.showInstantNotification();
      } else {
        // Jeśli użytkownik odmówił uprawnień -> cofamy przełącznik
        setState(() {
          _notificationsEnabled = false;
        });
        // Informujemy użytkownika o braku uprawnień
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Brak uprawnień do powiadomień.")),
          );
        }
      }
    } else {
      // SCENARIUSZ WYŁĄCZANIA:
      // Anulujemy wszystkie aktywne harmonogramy w systemie
      await NotificationService.cancelNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pobieramy aktualny motyw, aby dostosować kolory tła
    bool isDark = ThemeService.isDarkMode.value;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Ustawienia"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // === SEKCJA 1: WYGLĄD ===
          const Text("WYGLĄD", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),

          _buildSettingsTile(
            context,
            icon: Icons.dark_mode,
            title: "Tryb ciemny",
            isDark: isDark,
            trailing: Switch(
              value: isDark,
              activeColor: Colors.blueAccent,
              onChanged: (val) async {
                // Przełączenie motywu w serwisie i odświeżenie widoku
                await ThemeService.toggleTheme(val);
                setState((){});
              },
            ),
          ),

          const SizedBox(height: 24),

          // === SEKCJA 2: OGÓLNE ===
          const Text("OGÓLNE", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),

          // Przełącznik powiadomień
          _buildSettingsTile(
            context,
            icon: Icons.notifications_active,
            title: "Codzienne przypomnienie",
            isDark: isDark,
            trailing: Switch(
              value: _notificationsEnabled,
              activeColor: Colors.blueAccent,
              onChanged: _toggleNotifications, // Podpięcie logiki powiadomień
            ),
          ),

          const SizedBox(height: 8),

          // Przycisk resetowania danych (wyróżniony kolorem czerwonym)
          _buildSettingsTile(
            context,
            icon: Icons.delete_forever,
            title: "Resetuj dane",
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: _showResetConfirmation,
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          // Informacje o aplikacji i autorach
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: "O aplikacji",
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                      title: const Text("Fiszki Plus"),
                      content: const Text("12425 Filip Banasiak\n12434 Piotr Kowalski\nProjekt zaliczeniowy.")
                  )
              );
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// Pomocniczy widget budujący spójne kafelki ustawień.
  /// Pozwala zachować DRY (Don't Repeat Yourself) i jednolity styl.
  /// [icon] - Ikona opcji.
  /// [title] - Etykieta tekstowa.
  /// [trailing] - Element końcowy (np. przełącznik lub strzałka).
  /// [onTap] - Akcja po kliknięciu.
  Widget _buildSettingsTile(BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Subtelny cień dla efektu głębi
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.blueAccent).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor ?? Colors.blueAccent),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: textColor ?? (isDark ? Colors.white : Colors.black87))),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}