import 'package:flutter/material.dart';
import 'package:flashcards/data/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ... (funkcje _showResetConfirmation, _showAboutApp, zmienna _notificationsEnabled bez zmian) ...
  bool _notificationsEnabled = true;

  void _showResetConfirmation() {
    /* ... skopiuj ze starego kodu ... */
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Resetuj postępy"),
        content: const Text("Czy na pewno chcesz usunąć wszystkie postępy?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Anuluj")),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Resetuj")),
        ],
      ),
    );
  }
  void _showAboutApp() {
    /* ... skopiuj ze starego kodu ... */
    showDialog(context: context, builder: (context) => AlertDialog(title: Text("O apce"), content: Text("v1.0")));
  }


  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeService.isDarkMode.value;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Ustawienia", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        centerTitle: false,
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
              trailing: Switch(
                  value: isDark,
                  activeColor: Colors.blueAccent,
                  onChanged: (val) async {
                    await ThemeService.toggleTheme(val);
                    setState((){});
                  }
              ),
              isDark: isDark
          ),

          const SizedBox(height: 24),
          const Text("OGÓLNE", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          _buildSettingsTile(
              context,
              icon: Icons.notifications,
              title: "Powiadomienia",
              trailing: Switch(value: _notificationsEnabled, activeColor: Colors.blueAccent, onChanged: (v) => setState(()=>_notificationsEnabled=v)),
              isDark: isDark
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
              context,
              icon: Icons.delete_outline,
              title: "Resetuj postępy",
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: _showResetConfirmation,
              isDark: isDark
          ),

          const SizedBox(height: 24),
          _buildSettingsTile(
              context,
              icon: Icons.info_outline,
              title: "O aplikacji",
              onTap: _showAboutApp,
              isDark: isDark
          ),
        ],
      ),
    );
  }

  // Pomocniczy widget do budowania kafelków ustawień
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