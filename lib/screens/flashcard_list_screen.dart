import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/flashcard.dart';
import 'learning_screen.dart';
import '../data/storage_service.dart';

class FlashcardListScreen extends StatefulWidget {
  final Category category;

  const FlashcardListScreen({super.key, required this.category});

  @override
  State<FlashcardListScreen> createState() => _FlashcardListScreenState();
}

class _FlashcardListScreenState extends State<FlashcardListScreen> {

  Future<void> _saveData() async {
    List<Category> allCategories = await StorageService.loadCategories();
    int index = allCategories.indexWhere((c) => c.name == widget.category.name);
    if (index != -1) {
      allCategories[index] = widget.category;
      await StorageService.saveCategories(allCategories);
    }
  }

  // ... (Funkcje _editFlashcard, _deleteFlashcard, _addFlashcard skopiuj ze starego kodu - są identyczne logicznie, zmienia się tylko UI w build) ...
  // DLA UŁATWIENIA: Wklejam tu tylko jedną funkcję _addFlashcard jako przykład, reszta jest taka sama
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
            TextField(controller: q, decoration: const InputDecoration(labelText: "Pytanie")),
            TextField(controller: a, decoration: const InputDecoration(labelText: "Odpowiedź")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Anuluj")),
          FilledButton(
            onPressed: () {
              if (q.text.isNotEmpty && a.text.isNotEmpty) {
                setState(() {
                  widget.category.cards.add(Flashcard(question: q.text, answer: a.text));
                });
                _saveData();
              }
              Navigator.pop(context);
            },
            child: const Text("Dodaj"),
          ),
        ],
      ),
    );
  }

  // Funkcja edycji fiszki
  void _editFlashcard(int index) {
    final card = widget.category.cards[index];
    // Wypełniamy pola obecną treścią
    TextEditingController qController = TextEditingController(text: card.question);
    TextEditingController aController = TextEditingController(text: card.answer);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edytuj fiszkę"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qController,
              decoration: const InputDecoration(
                labelText: "Pytanie",
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: aController,
              decoration: const InputDecoration(
                labelText: "Odpowiedź",
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Anuluj"),
          ),
          FilledButton(
            onPressed: () {
              // Zapisujemy zmiany tylko, jeśli pola nie są puste
              if (qController.text.isNotEmpty && aController.text.isNotEmpty) {
                setState(() {
                  widget.category.cards[index] = Flashcard(
                    question: qController.text,
                    answer: aController.text,
                  );
                });
                _saveData(); // Zapis do pamięci telefonu
              }
              Navigator.pop(context);
            },
            child: const Text("Zapisz"),
          ),
        ],
      ),
    );
  }

  // Funkcja usuwania fiszki
  void _deleteFlashcard(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Usuń fiszkę"),
        content: const Text("Czy na pewno chcesz usunąć tę fiszkę? Tej operacji nie można cofnąć."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Anuluj"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red), // Czerwony kolor ostrzegawczy
            onPressed: () {
              setState(() {
                widget.category.cards.removeAt(index);
              });
              _saveData(); // Zapis usunięcia do pamięci telefonu
              Navigator.pop(context);
            },
            child: const Text("Usuń"),
          ),
        ],
      ),
    );
  }
  // Skopiuj sobie _editFlashcard i _deleteFlashcard ze starego pliku tutaj.

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // 1. Czyste tło
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black, // Ciemny tekst/ikony
        title: Hero(
          tag: widget.category.name,
          child: Material(
            color: Colors.transparent,
            child: Text(
              widget.category.name,
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_fill, size: 32, color: Colors.blueAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LearningScreen(cards: widget.category.cards)),
              );
            },
          )
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addFlashcard, // Upewnij się, że masz tę funkcję
        label: const Text("Nowa fiszka"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),

      body: widget.category.cards.isEmpty
          ? Center(child: Text("Brak fiszek. Dodaj pierwszą!", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.category.cards.length,
        itemBuilder: (context, index) {
          final card = widget.category.cards[index];

          // 2. Karta w stylu "Material 3" / "Deck"
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              title: Text(
                card.question,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  card.answer,
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: Colors.grey[400]),
                    onPressed: () => _editFlashcard(index), // Upewnij się, że masz tę funkcję
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                    onPressed: () => _deleteFlashcard(index), // Upewnij się, że masz tę funkcję
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}