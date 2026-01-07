import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/flashcard.dart';
import 'learning_screen.dart';
import '../data/storage_service.dart';

/// Ekran szczegółów kategorii. Wyświetla listę wszystkich fiszek w danej talii.
/// Pełni funkcję panelu zarządzania (CRUD):
/// 1. Dodawanie nowych fiszek (FloatingActionButton).
/// 2. Edycja i usuwanie istniejących (przyciski na liście).
/// 3. Uruchamianie trybu nauki (ikona Play w nagłówku).
class FlashcardListScreen extends StatefulWidget {
  final Category category;

  const FlashcardListScreen({super.key, required this.category});

  @override
  State<FlashcardListScreen> createState() => _FlashcardListScreenState();
}

class _FlashcardListScreenState extends State<FlashcardListScreen> {

  /// Zapisuje zmiany w pamięci urządzenia.
  /// Pobiera pełną listę kategorii, podmienia aktualnie edytowaną talię na nowszą wersję
  /// i zapisuje całość z powrotem do [StorageService].
  Future<void> _saveData() async {
    List<Category> allCategories = await StorageService.loadCategories();

    int index = allCategories.indexWhere((c) => c.name == widget.category.name);

    if (index != -1) {
      allCategories[index] = widget.category;
      await StorageService.saveCategories(allCategories);
    }
  }

  /// Wyświetla okno dialogowe z formularzem edycji fiszki.
  /// [index] wskazuje, którą fiszkę z listy edytujemy.
  void _editFlashcard(int index) {
    final card = widget.category.cards[index];

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
              decoration: const InputDecoration(labelText: "Pytanie", border: OutlineInputBorder()),
              minLines: 1, maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: aController,
              decoration: const InputDecoration(labelText: "Odpowiedź", border: OutlineInputBorder()),
              minLines: 1, maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Anuluj")),
          FilledButton(
            onPressed: () {
              if (qController.text.isNotEmpty && aController.text.isNotEmpty) {
                setState(() {
                  widget.category.cards[index] = Flashcard(
                    question: qController.text,
                    answer: aController.text,
                    isMastered: card.isMastered,
                  );
                });
                _saveData();
              }
              Navigator.pop(context);
            },
            child: const Text("Zapisz"),
          ),
        ],
      ),
    );
  }

  /// --- LOGIKA USUWANIA ---
  /// Wyświetla dialog potwierdzenia usunięcia fiszki.
  /// Jeśli użytkownik potwierdzi, usuwa element z listy i aktualizuje pamięć telefonu.
  void _deleteFlashcard(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Usuń fiszkę"),
        content: const Text("Czy na pewno chcesz usunąć tę fiszkę?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Anuluj")
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                // Usuwamy z pamięci RAM (z listy wyświetlanej na ekranie)
                widget.category.cards.removeAt(index);
              });
              // Zapisujemy nową (krótszą) listę do pamięci telefonu
              _saveData();
              Navigator.pop(context);
            },
            child: const Text("Usuń"),
          ),
        ],
      ),
    );
  }

  /// Wyświetla formularz dodawania nowej fiszki.
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        // Hero Animation: Płynne przejście tytułu
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
          // Przycisk rozpoczęcia nauki
          IconButton(
            icon: const Icon(Icons.play_circle_fill, size: 32, color: Colors.blueAccent),
            onPressed: () {
              // Sprawdzamy czy są fiszki, zanim przejdziemy do nauki
              if (widget.category.cards.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LearningScreen(category: widget.category),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Dodaj najpierw fiszki!"))
                );
              }
            },
          )
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addFlashcard,
        label: const Text("Nowa fiszka"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),

      body: widget.category.cards.isEmpty
          ? const Center(child: Text("Brak fiszek. Dodaj pierwszą!", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
        itemCount: widget.category.cards.length,
        itemBuilder: (context, index) {
          final card = widget.category.cards[index];

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
              border: card.isMastered
                  ? Border.all(color: Colors.green.withOpacity(0.5), width: 1.5)
                  : null,
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
                  // Ikona "Ptaszka" - jeśli umiana
                  if (card.isMastered)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                    ),

                  // Przycisk Edycji
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: Colors.grey[400]),
                    onPressed: () => _editFlashcard(index),
                  ),

                  // Przycisk USUWANIA (Czerwony kosz)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                    onPressed: () => _deleteFlashcard(index),
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