import 'dart:math'; // Potrzebne do 3D (liczba Pi)
import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class LearningScreen extends StatefulWidget {
  final List<Flashcard> cards;

  const LearningScreen({super.key, required this.cards});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
    with SingleTickerProviderStateMixin {

  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // --- ZMIENNE STANU ---
  int _currentIndex = 0; // Do licznika (np. 1/10)

  // Zmienna, której brakowało.
  // W trybie 3D stan określamy animacją, ale ta zmienna przydaje się do logiki
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Konfiguracja animacji obrotu
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

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

  void _flipCard() {
    if (_animationController.isDismissed) {
      _animationController.forward();
      setState(() => _showAnswer = true);
    } else {
      _animationController.reverse();
      setState(() => _showAnswer = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int totalCards = widget.cards.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF0F2F5),

      appBar: AppBar(
        title: Column(
          children: [
            const Text("Tryb nauki"),
            // Licznik pod tytułem
            Text(
              "${_currentIndex + 1} / $totalCards",
              style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        centerTitle: true,
        // Pasek postępu na dole AppBara
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            // Zabezpieczenie przed dzieleniem przez zero
            value: (totalCards > 0) ? ((_currentIndex + 1) / totalCards) : 0,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            minHeight: 4,
          ),
        ),
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
              // Resetowanie stanu przy zmianie karty
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;      // Aktualizujemy licznik
                  _showAnswer = false;        // Resetujemy zmienną pomocniczą
                  _animationController.reset(); // Resetujemy animację (wracamy do pytania)
                });
              },
              itemBuilder: (context, index) {
                final card = widget.cards[index];

                // --- ANIMACJA 3D ---
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    double angle = _animation.value * pi;
                    bool isBack = angle >= (pi / 2);

                    final matrix = Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle);

                    return GestureDetector(
                      onTap: _flipCard,
                      child: Transform(
                        transform: matrix,
                        alignment: Alignment.center,
                        child: isBack
                            ? Transform(
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