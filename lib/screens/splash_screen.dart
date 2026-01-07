import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

/// Ekran powitalny (Splash Screen).
/// Jest to pierwszy widok, który widzi użytkownik po uruchomieniu aplikacji.
/// Pełni dwie funkcje:
/// 1. Buduje tożsamość wizualną marki (Logo, Nazwa).
/// 2. Symuluje (lub wykonuje) ładowanie danych startowych przed przejściem do menu głównego.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  /// Metoda wywoływana jednokrotnie przy tworzeniu stanu widgetu.
  /// Idealne miejsce na inicjalizację timerów lub logiki startowej.
  @override
  void initState() {
    super.initState();

    // Ustawiamy timer na 2 sekundy.
    // W rozbudowanej aplikacji w tym miejscu moglibyśmy ładować dane z bazy,
    // sprawdzać czy użytkownik jest zalogowany lub inicjalizować serwisy.
    Timer(const Duration(seconds: 2), () {
      // Po upływie czasu przechodzimy do ekranu głównego (HomeScreen).
      // Używamy pushReplacement, aby zastąpić Splash Screen w historii nawigacji.
      // Dzięki temu użytkownik klikając "Wstecz" w menu głównym, wyjdzie z aplikacji,
      // zamiast wrócić do ekranu ładowania.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sprawdzamy aktualny motyw systemu (Jasny/Ciemny),
    // aby dostosować kolory gradientu w tle.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Kontener z gradientem jako tło całego ekranu.
      // Zastępuje standardowy 'backgroundColor' ze Scaffolda.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // Dynamiczny dobór kolorów w zależności od trybu
            colors: isDark
                ? [const Color(0xFF2C3E50), const Color(0xFF000000)] // Ciemny: Elegancki granat przechodzący w czerń
                : [Colors.blueAccent, Colors.lightBlueAccent],       // Jasny: Energetyczny niebieski gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              // Ikona aplikacji (Logo)
              Icon(
                Icons.school,
                size: 100,
                color: Colors.white, // Biały kolor zapewnia doskonały kontrast na obu gradientach
              ),
              SizedBox(height: 20),

              // Nazwa aplikacji
              Text(
                "Fiszki Plus",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),

              // Animowany wskaźnik ładowania (sugeruje użytkownikowi, że aplikacja pracuje)
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}