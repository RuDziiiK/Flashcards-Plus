import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/flashcard.dart';
import 'learning_screen.dart';
import '../data/storage_service.dart'; // Konieczny import do zapisu!

class FlashcardListScreen extends StatefulWidget {
  final Category category;

  const FlashcardListScreen({super.key, required this.category});

  @override
  State<FlashcardListScreen> createState() => _FlashcardListScreenState();
}

class _FlashcardListScreenState extends State<FlashcardListScreen> {

  // Funkcja pomocnicza: Zapisuje zmiany w pamięci telefonu
  // Musimy pobrać całą listę kategorii, zaktualizować tę jedną i zapisać całość.
  Future<void> _saveData() async {
    // 1. Pobieramy aktualną listę wszystkich kategorii z dysku
    List<Category> allCategories = await StorageService.loadCategories();

    // 2. Szukamy indeksu aktualnie edytowanej kategorii (po nazwie)
    int index = allCategories.indexWhere((c) => c.name == widget.category.name);

    if (index != -1) {
      // 3. Podmieniamy starą wersję kategorii na nową (zaktualizowaną w pamięci)
      allCategories[index] = widget.category;

      // 4. Zapisujemy całość z powrotem do telefonu
      await StorageService.saveCategories(allCategories);
    }
  }

  void _editFlashcard(int index) {
    final card = widget.category.cards[index];
    TextEditingController q = TextEditingController(text: card.question);
    TextEditingController a = TextEditingController(text: card.answer);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edytuj fiszkę"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: q,
              decoration: const InputDecoration(labelText: "Pytanie"),
            ),
            TextField(
              controller: a,
              decoration: const InputDecoration(labelText: "Odpowiedź"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Anuluj"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.category.cards[index] = Flashcard(
                  question: q.text,
                  answer: a.text,
                );
              });
              _saveData(); // <--- ZAPISUJEMY ZMIANY
              Navigator.pop(context);
            },
            child: const Text("Zapisz"),
          ),
        ],
      ),
    );
  }

  void _deleteFlashcard(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Usuń fiszkę"),
        content: const Text("Czy na pewno chcesz usunąć tę fiszkę?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Anuluj"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.category.cards.removeAt(index);
              });
              _saveData(); // <--- ZAPISUJEMY ZMIANY
              Navigator.pop(context);
            },
            child: const Text("Usuń", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addFlashcard() {
    TextEditingController q = TextEditingController();
    TextEditingController a = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Dodaj fiszkę"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: q,
              decoration: const InputDecoration(labelText: "Pytanie"),
            ),
            TextField(
              controller: a,
              decoration: const InputDecoration(labelText: "Odpowiedź"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Anuluj"),
          ),
          TextButton(
            onPressed: () {
              if (q.text.isNotEmpty && a.text.isNotEmpty) {
                setState(() {
                  widget.category.cards.add(
                    Flashcard(question: q.text, answer: a.text),
                  );
                });
                _saveData(); // <--- ZAPISUJEMY ZMIANY
              }
              Navigator.pop(context);
            },
            child: const Text("Dodaj"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sprawdzamy tryb ciemny dla dostosowania kolorów
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      LearningScreen(cards: widget.category.cards),
                ),
              );
            },
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addFlashcard,
        child: const Icon(Icons.add),
        // Kolor przycisku w zależności od motywu (opcjonalnie)
        backgroundColor: isDark ? Colors.indigoAccent : Colors.blueAccent,
      ),

      body: Container(
        // 1. DYNAMICZNY GRADIENT TŁA (taki sam jak w CategoryScreen)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2C3E50), const Color(0xFF000000)]
                : [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          itemCount: widget.category.cards.length,
          itemBuilder: (context, index) {
            final card = widget.category.cards[index];

            return Card(
              // 2. DYNAMICZNY KOLOR KARTY
              color: isDark ? Colors.grey[800] : Colors.white.withOpacity(0.9),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  card.question,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  card.answer,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: isDark ? Colors.blueAccent : Colors.blue),
                      onPressed: () => _editFlashcard(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteFlashcard(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}