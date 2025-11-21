import 'package:flutter/material.dart';
import 'package:flashcards/screens/category_screen.dart';
import 'package:flashcards/screens/settings_screen.dart';
// Importujemy learning_screen nie jest tu konieczny bezpośrednio,
// bo nawigujemy do niego przez CategoryScreen(selectMode: true)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animacja pulsowania ikony
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.9, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Funkcja tworząca przycisk (zaktualizowana o obsługę motywu)
  Widget _buildMenuButton(String text, VoidCallback onPressed, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(50)),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                // Kolor po naciśnięciu
                return isDark ? Colors.grey[700]! : Colors.lightBlueAccent;
              }
              // Kolor domyślny: Ciemnoszary dla dark mode, Niebieski dla light mode
              return isDark ? Colors.grey[800]! : Colors.lightBlue;
            },
          ),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          animationDuration: const Duration(milliseconds: 400),
          elevation: WidgetStateProperty.all(8),
          shadowColor: WidgetStateProperty.all(Colors.black87),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                // Kolor obramowania: Indigo dla dark mode, BlueAccent dla light mode
                color: isDark ? Colors.indigoAccent : Colors.blueAccent,
                width: 2,
              ),
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Sprawdzamy motyw
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        // 2. Dynamiczny Gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2C3E50), const Color(0xFF000000)] // Ciemny
                : [Colors.blueAccent, Colors.lightBlueAccent],       // Jasny
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 50),
              // Animowana Ikona
              ScaleTransition(
                scale: _animation,
                child: const Icon(
                  Icons.school,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              // Tytuł
              const Text(
                'Fiszki Plus',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              // Podtytuł
              const Text(
                'szybkie przypominanie, że coś pamiętasz',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              // Menu z przyciskami
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30),
                child: Column(
                  children: [
                    _buildMenuButton('Rozpocznij naukę', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoryScreen(selectMode: true),
                        ),
                      );
                    }, isDark),

                    _buildMenuButton('Kategorie fiszek', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CategoryScreen()),
                      );
                    }, isDark),

                    _buildMenuButton('Ustawienia', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    }, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}