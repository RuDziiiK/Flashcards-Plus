import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Czekaj 2 sekundy i przejdź do ekranu głównego
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Sprawdzamy tryb (jasny/ciemny)
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Usuwamy backgroundColor, bo zastąpi go Container z gradientem
      body: Container(
        // 2. Dynamiczny Gradient - spójny z resztą aplikacji
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2C3E50), const Color(0xFF000000)] // Ciemny gradient
                : [Colors.blueAccent, Colors.lightBlueAccent],       // Jasny gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.school,
                size: 100,
                color: Colors.white, // Biel wygląda dobrze na obu naszych gradientach
              ),
              SizedBox(height: 20),
              Text(
                "Fiszki Plus", // Możesz tu wpisać nazwę swojej aplikacji
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
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