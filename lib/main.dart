import 'package:flutter/material.dart';

void main() {
  runApp(const FlashcardsApp());
}

class FlashcardsApp extends StatelessWidget {
  const FlashcardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcards Plus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const FlashcardHomePage(),
    );
  }
}

class Flashcard {
  final String question;
  final String answer;

  Flashcard(this.question, this.answer);
}

class FlashcardHomePage extends StatefulWidget {
  const FlashcardHomePage({super.key});

  @override
  State<FlashcardHomePage> createState() => _FlashcardHomePageState();
}

class _FlashcardHomePageState extends State<FlashcardHomePage> {
  final List<Flashcard> flashcards = [
    Flashcard('Hello', 'Cześć'),
    Flashcard('Dog', 'Pies'),
    Flashcard('Apple', 'Jabłko'),
    Flashcard('Book', 'Książka'),
  ];

  int currentIndex = 0;
  bool showAnswer = false;

  void nextCard() {
    setState(() {
      showAnswer = false;
      if (currentIndex < flashcards.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }
    });
  }

  void previousCard() {
    setState(() {
      showAnswer = false;
      if (currentIndex > 0) {
        currentIndex--;
      } else {
        currentIndex = flashcards.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = flashcards[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards Plus'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() => showAnswer = !showAnswer),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.indigo[100],
                child: SizedBox(
                  width: 300,
                  height: 200,
                  child: Center(
                    child: Text(
                      showAnswer ? card.answer : card.question,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: previousCard,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Poprzednia'),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: nextCard,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Następna'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
