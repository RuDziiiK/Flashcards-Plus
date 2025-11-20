import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/flashcard.dart';
import 'learning_screen.dart';

class FlashcardListScreen extends StatefulWidget {
  final Category category;

  const FlashcardListScreen({super.key, required this.category});

  @override
  State<FlashcardListScreen> createState() => _FlashcardListScreenState();
}

class _FlashcardListScreenState extends State<FlashcardListScreen> {

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
              Navigator.pop(context);
            },
            child: const Text("Usuń"),
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
      ),

      body: ListView.builder(
        itemCount: widget.category.cards.length,
        itemBuilder: (context, index) {
          final card = widget.category.cards[index];

          return Card(
            child: ListTile(
              title: Text(card.question),
              subtitle: Text(card.answer),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editFlashcard(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
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
