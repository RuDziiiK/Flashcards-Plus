import 'dart:math'; // Potrzebne do liczby Pi i obrotów 3D
import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class LearningScreen extends StatefulWidget {
  final List<Flashcard> cards;

  const LearningScreen({super.key, required this.cards});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
    with SingleTickerProviderStateMixin { // Mixin potrzebny do animacji

  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Kontroler animacji obrotu (czas trwania: 0.6 sekundy)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Definicja animacji: od 0 do 1 (reprezentuje kąt od 0 do 180 stopni)
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Funkcja uruchamiająca obrót
  void _flipCard() {
    if (_animationController.isDismissed) {
      _animationController.forward(); // Obróć na tył
    } else {
      _animationController.reverse(); // Wróć na przód
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF0F2F5),

      appBar: AppBar(
        title: const Text("Tryb nauki"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        centerTitle: true,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Dotknij karty, aby odwrócić",
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.cards.length,
              // Ważne: Resetujemy kartę na "przód" przy zmianie slajdu
              onPageChanged: (_) {
                _animationController.reset();
              },
              itemBuilder: (context, index) {
                final card = widget.cards[index];

                // --- ANIMACJA 3D ---
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    // Obliczamy kąt obrotu w radianach (0 do PI)
                    double angle = _animation.value * pi;

                    // Sprawdzamy, czy jesteśmy już "za połową" obrotu
                    bool isBack = angle >= (pi / 2);

                    // Macierz transformacji 3D
                    final matrix = Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspektywa (głębia)
                      ..rotateY(angle);       // Obrót wokół osi Y

                    return GestureDetector(
                      onTap: _flipCard,
                      child: Transform(
                        transform: matrix,
                        alignment: Alignment.center,
                        child: isBack
                            ? Transform(
                          // Jeśli to tył, musimy go odbić lustrzanie, żeby tekst był czytelny
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(pi),
                          child: _buildCardContent(card, true, isDark),
                        )
                            : _buildCardContent(card, false, isDark),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // Wydzielony widget wyglądu karty (wspólny dla przodu i tyłu)
  Widget _buildCardContent(Flashcard card, bool isBack, bool isDark) {
    return Center(
      child: Container(
        width: 320,
        height: 480,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
          // Opcjonalnie: Delikatna ramka wskazująca, że to odpowiedź (zielona) lub pytanie (niebieska)
          border: Border.all(
            color: isBack
                ? Colors.green.withOpacity(0.3)
                : Colors.blueAccent.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Etykieta (PYTANIE / ODPOWIEDŹ)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isBack
                    ? Colors.green.withOpacity(0.1)
                    : Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isBack ? "ODPOWIEDŹ" : "PYTANIE",
                style: TextStyle(
                  color: isBack ? Colors.green : Colors.blueAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            const Spacer(),

            // Główny tekst
            Text(
              isBack ? card.answer : card.question,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.3,
              ),
            ),

            const Spacer(),

            // Ikona na dole (podpowiedź wizualna)
            Icon(
              isBack ? Icons.check_circle_outline : Icons.help_outline,
              size: 30,
              color: Colors.grey[400],
            )
          ],
        ),
      ),
    );
  }
}