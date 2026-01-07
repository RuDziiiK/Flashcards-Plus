import 'package:flutter/material.dart';
import '../data/storage_service.dart';
import '../models/user_profile.dart';

/// Ekran profilu użytkownika.
/// Prezentuje elementy grywalizacji i statystyki:
/// 1. Awatar i imię (z możliwością edycji).
/// 2. Pasek postępu poziomu (Level Bar).
/// 3. Kafelki ze statystykami (Dni z rzędu, Liczba kart).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Przechowuje dane użytkownika pobrane z pamięci
  UserProfile? _profile;

  // Flaga sterująca wyświetlaniem wskaźnika ładowania (CircularProgressIndicator)
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Pobieramy dane natychmiast po załadowaniu ekranu
    _loadProfile();
  }

  /// Asynchronicznie pobiera profil użytkownika z [StorageService].
  /// Po pobraniu aktualizuje stan, aby odświeżyć widok.
  Future<void> _loadProfile() async {
    UserProfile p = await StorageService.loadUserProfile();
    setState(() {
      _profile = p;
      _isLoading = false; // Dane pobrane, ukrywamy loader
    });
  }

  /// Wyświetla okno dialogowe z polem tekstowym do zmiany imienia.
  /// Po zatwierdzeniu zapisuje nowe imię w pamięci trwałej i odświeża UI.
  void _editName() {
    TextEditingController controller = TextEditingController(text: _profile?.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Zmień imię"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Twoje imię"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Anuluj")),
          FilledButton(
            onPressed: () {
              setState(() {
                // Aktualizacja w pamięci RAM
                _profile!.name = controller.text;
              });
              // Aktualizacja w pamięci trwałej (telefonu)
              StorageService.saveUserProfile(_profile!);
              Navigator.pop(context);
            },
            child: const Text("Zapisz"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Jeśli dane się jeszcze ładują, wyświetlamy kółko ładowania
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // 1. SEKCJA NAGŁÓWKA (Header)
            // ==========================================
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                // Cień pod nagłówkiem dla efektu głębi
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  // Awatar z pierwszą literą imienia i przyciskiem edycji
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blueAccent.withOpacity(0.2),
                        child: Text(
                          _profile!.name.isNotEmpty ? _profile!.name[0].toUpperCase() : "?",
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                      ),
                      GestureDetector(
                        onTap: _editName,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Imię i Poziom
                  Text(
                    _profile!.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    "Poziom ${_profile!.level}",
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==========================================
            // 2. SEKCJA POSTĘPU (Level Bar)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Postęp poziomu", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                        // Wyświetlamy procent (np. 50%)
                        Text("${(_profile!.levelProgress * 100).toInt()}%", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Wizualny pasek postępu
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _profile!.levelProgress,
                        minHeight: 10,
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Podpowiedź dla użytkownika (ile kart brakuje do awansu)
                    Text(
                      "Utwórz jeszcze ${10 - (_profile!.totalCardsCreated % 10)} kart, aby awansować!",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==========================================
            // 3. SIATKA STATYSTYK
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Statystyka: Dni z rzędu (Streak)
                  Expanded(
                    child: _buildStatCard(
                      "Dni z rzędu",
                      "${_profile!.studyStreak}",
                      Icons.local_fire_department,
                      Colors.orange,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Statystyka: Łączna liczba kart
                  Expanded(
                    child: _buildStatCard(
                      "Wszystkie karty",
                      "${_profile!.totalCardsCreated}",
                      Icons.style,
                      Colors.purpleAccent,
                      isDark,
                    ),
                  ),
                ],
              ),
            ),

            // Dodatkowy odstęp na dole, aby treść nie chowała się pod paskiem nawigacji
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// Pomocnicza metoda budująca spójne wizualnie kafelki statystyk.
  /// Pozwala uniknąć powielania kodu (DRY - Don't Repeat Yourself).
  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikona w kolorowym kółku
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          // Wartość liczbowa (duża czcionka)
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          // Tytuł statystyki (szara czcionka)
          Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }
}