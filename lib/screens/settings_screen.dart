import 'package:flutter/material.dart';
import 'package:flashcards/data/theme_service.dart';
import 'package:flashcards/data/storage_service.dart';
import 'package:flashcards/data/notification_service.dart';
// TO JEST LINIA, KTÓREJ BRAKOWAŁO:
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Wczytywanie stanu przełącznika przy starcie
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    });
  }

  // Funkcja Resetu
  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Resetuj postępy"),
        content: const Text("Czy na pewno chcesz usunąć wszystkie dane?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Anuluj")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await StorageService.clearAllData();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Dane zresetowane.")),
                );
              }
            },
            child: const Text("Resetuj"),
          ),
        ],
      ),
    );
  }

  // Nowa logika przełącznika (dla Awesome Notifications)
  void _toggleNotifications(bool value) async {
    // 1. Zmieniamy stan wizualnie
    setState(() {
      _notificationsEnabled = value;
    });

    // 2. Zapisujemy w pamięci
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);

    if (value) {
      // 3. Włączamy: Pytamy o zgodę
      bool allowed = await NotificationService.requestPermissions();

      if (allowed) {
        // Jeśli zgoda jest -> planujemy powiadomienia
        await NotificationService.scheduleDailyNotification();
        await NotificationService.showInstantNotification();
      } else {
        // Jeśli brak zgody -> cofamy przełącznik
        setState(() {
          _notificationsEnabled = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Brak uprawnień do powiadomień.")),
          );
        }
      }
    } else {
      // 4. Wyłączamy: Anulujemy powiadomienia
      await NotificationService.cancelNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                await ThemeService.toggleTheme(val);
                setState((){});
              },
            ),
          ),

          const SizedBox(height: 24),
          const Text("OGÓLNE", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),

          _buildSettingsTile(
            context,
            icon: Icons.notifications_active,
            title: "Codzienne przypomnienie",
            isDark: isDark,
            trailing: Switch(
              value: _notificationsEnabled,
              activeColor: Colors.blueAccent,
              onChanged: _toggleNotifications,
            ),
          ),

          const SizedBox(height: 8),

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
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: "O aplikacji",
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                      title: const Text("Fiszki Plus"),
                      content: const Text("Wersja 1.0\nProjekt zaliczeniowy.")
                  )
              );
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

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