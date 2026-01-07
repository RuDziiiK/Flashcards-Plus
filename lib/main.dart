import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flashcards/screens/splash_screen.dart';
import 'package:flashcards/data/theme_service.dart';
import 'package:flashcards/data/notification_service.dart';

/// Główna funkcja startowa aplikacji.
/// Tutaj odbywa się inicjalizacja wszystkich kluczowych serwisów (Baza danych, Powiadomienia, Motywy)
/// zanim zostanie narysowany interfejs graficzny.
void main() async {
  // Wymagane, aby móc wykonywać operacje asynchroniczne (await) przed uruchomieniem runApp().
  // Łączy warstwę Fluttera z silnikiem natywnym.
  WidgetsFlutterBinding.ensureInitialized();

  // --- 2. BLOKADA ORIENTACJI (TYLKO PION) ---
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Wczytujemy zapamiętany przez użytkownika motyw (Jasny/Ciemny) z pamięci telefonu.
  await ThemeService.loadThemePreference();

  // Inicjalizujemy system powiadomień lokalnych (tworzenie kanałów Androida).
  await NotificationService.init();

  // Uruchamiamy główny widget aplikacji.
  runApp(const FlashcardsApp());
}

/// Główny widget (Root) całej aplikacji.
/// Odpowiada za konfigurację:
/// 1. Globalnych motywów (ThemeData) - kolory, czcionki.
/// 2. Reaktywności na zmianę trybu ciemnego.
/// 3. Ekranu startowego.
class FlashcardsApp extends StatelessWidget {
  const FlashcardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder nasłuchuje zmian w serwisie motywów.
    // Dzięki temu, gdy użytkownik przełączy motyw w ustawieniach,
    // cała aplikacja odświeży się natychmiast, bez konieczności restartu.
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.isDarkMode,
      builder: (context, isDark, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fiszki Plus',

          // ==========================================
          // KONFIGURACJA MOTYWU JASNEGO (Light Mode)
          // ==========================================
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.light,
              surface: const Color(0xFFF5F7FA),
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F7FA),

            // Globalna konfiguracja typografii.
            // Używamy czcionki 'Poppins' dla nowoczesnego, czytelnego wyglądu.
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),

            // Domyślny styl paska nawigacji górnej
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
            ),
          ),

          // ==========================================
          // KONFIGURACJA MOTYWU CIEMNEGO (Dark Mode)
          // ==========================================
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E1E),
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),

            // Typografia dla trybu ciemnego
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),

            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
            ),
          ),

          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

          // Pierwszy ekran, jaki zobaczy użytkownik
          home: const SplashScreen(),
        );
      },
    );
  }
}