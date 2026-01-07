import 'package:flutter/material.dart';
import 'package:flashcards/screens/category_screen.dart';
import 'package:flashcards/screens/settings_screen.dart';
import 'package:flashcards/screens/profile_screen.dart';
import 'package:flashcards/data/notification_service.dart';
import 'package:flashcards/data/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Główny ekran aplikacji (szkielet nawigacyjny).
/// Zawiera dolny pasek nawigacji (BottomNavigationBar) i zarządza przełączaniem
/// pomiędzy głównymi widokami: Talie, Profil, Ustawienia.
/// Odpowiada również za logikę startową (powiadomienia, aktualizacja streaka).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Indeks aktualnie wybranej zakładki (0 = Talie, 1 = Profil, 2 = Ustawienia)
  int _currentIndex = 0;

  // Lista ekranów odpowiadająca kolejności ikon w pasku nawigacji
  final List<Widget> _screens = [
    const CategoryScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // 1. Sprawdzenie i prośba o powiadomienia
    // Używamy Future.delayed(Duration.zero), aby kod wykonał się po zbudowaniu pierwszej klatki UI.
    // Zapobiega to błędom kontekstu przy wyświetlaniu dialogów systemowych.
    Future.delayed(Duration.zero, () {
      _checkAndAskForNotifications();
    });

    // 2. Aktualizacja statystyk w tle
    // Wywołujemy to tutaj, aby licznik "Dni z rzędu" (Streak) zaktualizował się
    // od razu po otwarciu aplikacji, nawet jeśli użytkownik nie wejdzie w zakładkę Profil.
    StorageService.loadUserProfile();
  }

  /// Sprawdza status zgody na powiadomienia przy pierwszym uruchomieniu.
  /// Jeśli użytkownik nie wyłączył ich ręcznie, aplikacja poprosi o uprawnienia.
  Future<void> _checkAndAskForNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    // null = użytkownik jeszcze nie decydował (pierwsze uruchomienie)
    // true = włączone, false = wyłączone ręcznie
    bool? userDisabled = prefs.getBool('notifications_enabled');

    // Jeśli to pierwsze uruchomienie lub powiadomienia są aktywne:
    if (userDisabled != false) {
      // 1. Prosimy system o uprawnienia (Android 13+)
      await NotificationService.requestPermissions();

      // 2. Planujemy codzienne przypomnienie
      await NotificationService.scheduleDailyNotification();

      // 3. Zapisujemy stan w ustawieniach
      await prefs.setBool('notifications_enabled', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Pobieramy kolor tła z globalnego motywu (zdefiniowanego w main.dart)
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // extendBody: true pozwala treści (body) wchodzić pod pasek nawigacji.
      // Jest to konieczne, aby uzyskać efekt "pływającego" paska z przezroczystością.
      extendBody: true,

      // Wyświetlamy ekran zgodny z aktualnym indeksem
      body: _screens[_currentIndex],

      // --- NOWOCZESNY PASEK NAWIGACJI ---
      // Zamiast standardowego paska, tworzymy go w kontenerze z marginesami i zaokrągleniami.
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          // Dodajemy cień, aby pasek "unosił się" nad treścią
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        // ClipRRect przycina dziecko (NavigationBar) do zaokrąglonych rogów kontenera
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: NavigationBar(
            height: 70,
            backgroundColor: Colors.transparent, // Przezroczyste tło (kolor nadaje Container wyżej)
            indicatorColor: Colors.blueAccent.withOpacity(0.15), // Kolor aktywnej zakładki
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            // Ukrywamy etykiety tekstowe, aby uzyskać minimalistyczny wygląd (tylko ikony)
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.style_outlined, color: isDark ? Colors.grey : Colors.grey[600]),
                selectedIcon: const Icon(Icons.style, color: Colors.blueAccent),
                label: 'Talie',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: isDark ? Colors.grey : Colors.grey[600]),
                selectedIcon: const Icon(Icons.person, color: Colors.blueAccent),
                label: 'Profil',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined, color: isDark ? Colors.grey : Colors.grey[600]),
                selectedIcon: const Icon(Icons.settings, color: Colors.blueAccent),
                label: 'Ustawienia',
              ),
            ],
          ),
        ),
      ),
    );
  }
}