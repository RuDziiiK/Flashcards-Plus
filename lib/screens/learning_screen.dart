import 'dart:math'; // Potrzebne do obliczeń kątów (liczba Pi) przy animacji 3D
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/flashcard.dart';
import '../data/storage_service.dart';

/// Ekran trybu nauki.
/// To tutaj odbywa się główna interakcja użytkownika z aplikacją:
/// 1. Wyświetlanie fiszek w formie talii.
/// 2. Animowane odwracanie kart (efekt 3D).
/// 3. Ocenianie wiedzy ("Umiem" / "Jeszcze nie"), co wpływa na statystyki.
class LearningScreen extends StatefulWidget {
  final Category category;

  const LearningScreen({super.key, required this.category});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
    with SingleTickerProviderStateMixin { // Mixin wymagany do obsługi AnimationController

  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Indeks aktualnie wyświetlanej karty
  int _currentIndex = 0;
  // Flaga określająca, czy widzimy odpowiedź (tył karty)
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Konfiguracja kontrolera animacji (czas trwania obrotu: 600ms)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Definicja krzywej animacji (CurvedAnimation sprawia, że ruch jest bardziej naturalny)
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    // Pamiętamy o zwolnieniu zasobów kontrolerów
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Obsługuje logikę obracania karty.
  /// Uruchamia animację do przodu (pokazanie odpowiedzi) lub do tyłu (powrót do pytania).
  void _flipCard() {
    if (_animationController.isDismissed) {
      _animationController.forward();
      setState(() => _showAnswer = true);
    } else {
      _animationController.reverse();
      setState(() => _showAnswer = false);
    }
  }

  /// Zapisuje wynik nauki dla bieżącej karty i przechodzi do następnej.
  /// [isKnown] - true jeśli kliknięto "Umiem", false jeśli "Jeszcze nie".
  Future<void> _markCard(bool isKnown) async {
    setState(() {
      // 1. Aktualizacja stanu w pamięci podręcznej (RAM)
      widget.category.cards[_currentIndex].isMastered = isKnown;
    });

    // 2. Trwały zapis zmian w pamięci urządzenia (StorageService)
    List<Category> allCats = await StorageService.loadCategories();
    // Szukamy aktualnej kategorii w pełnej liście, aby ją podmienić
    int index = allCats.indexWhere((c) => c.name == widget.category.name);

    if (index != -1) {
      allCats[index] = widget.category;
      await StorageService.saveCategories(allCats);
    }

    // 3. Nawigacja do następnej karty (jeśli istnieje)
    if (_currentIndex < widget.category.cards.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // Koniec talii - wyświetlamy podsumowanie
      _showCompletionDialog();
    }
  }

  /// Wyświetla modal z gratulacjami po ukończeniu wszystkich fiszek w talii.
  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Koniec talii!"),
        content: const Text("Przejrzałeś wszystkie fiszki."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Zamknij dialog
              Navigator.pop(context); // Wróć do poprzedniego ekranu (listy talii)
            },
            child: const Text("Wróć do menu"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int totalCards = widget.category.cards.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF0F2F5),

      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.category.name),
            // Licznik postępu tekstowy (np. "1 / 10")
            Text(
              "${_currentIndex + 1} / $totalCards",
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        centerTitle: true,
        // Pasek postępu (LinearProgressIndicator) na dole AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
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

          // Główny obszar kart (PageView)
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.category.cards.length,
              // Blokujemy przewijanie palcem, wymuszając użycie przycisków oceny
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _showAnswer = false;
                  // Resetujemy animację przy zmianie karty (zawsze zaczynamy od pytania)
                  _animationController.reset();
                });
              },
              itemBuilder: (context, index) {
                final card = widget.category.cards[index];

                // --- LOGIKA ANIMACJI 3D ---
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    // Obliczamy kąt obrotu w radianach (0 do PI)
                    double angle = _animation.value * pi;
                    // Sprawdzamy czy przekroczyliśmy 90 stopni (czy pokazać tył)
                    bool isBack = angle >= (pi / 2);

                    // Macierz transformacji 3D
                    final matrix = Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Nadanie perspektywy (głębi)
                      ..rotateY(angle);       // Obrót wokół osi Y

                    return GestureDetector(
                      onTap: _flipCard,
                      child: Transform(
                        transform: matrix,
                        alignment: Alignment.center,
                        child: isBack
                            ? Transform(
                          // Jeśli pokazujemy tył, musimy go obrócić o 180 stopni (PI),
                          // aby tekst nie był lustrzanym odbiciem
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

          // --- PRZYCISKI OCENY (Dolny pasek) ---
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // Przycisk "Jeszcze nie" (Czerwony)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _markCard(false),
                    icon: const Icon(Icons.close),
                    label: const Text("Jeszcze nie"),
                  ),
                ),
                const SizedBox(width: 16),
                // Przycisk "Umiem" (Zielony)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.1),
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _markCard(true),
                    icon: const Icon(Icons.check),
                    label: const Text("Umiem"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Pomocnicza metoda budująca wygląd pojedynczej strony karty (przód lub tył).
  Widget _buildCardContent(Flashcard card, bool isBack, bool isDark) {
    return Center(
      child: Container(
        width: 320,
        height: 400,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          // Cień pod kartą (efekt lewitacji)
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
          // Kolorowa ramka zależna od strony karty (Niebieska - Pytanie, Zielona - Odpowiedź)
          border: Border.all(
            color: isBack ? Colors.green.withOpacity(0.3) : Colors.blueAccent.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Etykieta góra (PYTANIE / ODPOWIEDŹ)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isBack ? Colors.green.withOpacity(0.1) : Colors.blueAccent.withOpacity(0.1),
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
            // Główna treść karty
            Text(
              isBack ? card.answer : card.question,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.3,
              ),
            ),
            const Spacer(),
            // Ikona statusu (widoczna tylko jeśli użytkownik już wcześniej zaliczył tę kartę)
            if (card.isMastered && !isBack)
              const Icon(Icons.check_circle, color: Colors.green, size: 24)
            else
              Icon(isBack ? Icons.check_circle_outline : Icons.help_outline, size: 30, color: Colors.grey[400])
          ],
        ),
      ),
    );
  }
}