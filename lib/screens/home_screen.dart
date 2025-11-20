import 'package:flutter/material.dart';
import 'package:flashcards/screens/category_screen.dart';
import 'package:flashcards/screens/learning_screen.dart';
import 'package:flashcards/data/data.dart';


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

  // Funkcja tworząca przycisk
  Widget _buildMenuButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(50)),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.lightBlueAccent; // kolor po kliknięciu
              }
              return Colors.lightBlue; // kolor domyślny
            },
          ),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          animationDuration: const Duration(milliseconds: 400),
          elevation: WidgetStateProperty.all(8),
          shadowColor: WidgetStateProperty.all(Colors.black87),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.blueAccent, width: 2),
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
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
              ScaleTransition(
                scale: _animation,
                child: const Icon(
                  Icons.school,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Fiszki',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'szybkie przypominanie, że coś pamiętasz',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
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
                    }),
                    _buildMenuButton('Kategorie fiszek', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CategoryScreen()),
                      );
                    }),
                    _buildMenuButton('Ustawienia', () {}),
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
