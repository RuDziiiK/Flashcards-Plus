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
  void _addFlashcard() {
    TextEditingController questionCtrl = TextEditingController();
    TextEditingController answerCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Dodaj fiszkę"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionCtrl,
              decoration: const InputDecoration(labelText: "Pytanie"),
            ),
            TextField(
              controller: answerCtrl,
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
              if (questionCtrl.text.isNotEmpty &&
                  answerCtrl.text.isNotEmpty) {
                setState(() {
                  widget.category.cards.add(
                    Flashcard(
                      question: questionCtrl.text,
                      answer: answerCtrl.text,
                    ),
                  );
                });
                Navigator.pop(context);
              }
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
            icon: const Icon(Icons.add),
            onPressed: _addFlashcard,
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          itemCount: widget.category.cards.length,
          itemBuilder: (_, index) {
            final card = widget.category.cards[index];
            return Card(
              margin: const EdgeInsets.all(12),
              color: Colors.white.withOpacity(0.9),
              child: ListTile(
                title: Text(card.question),
                subtitle: Text(card.answer),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LearningScreen(
                        cards: widget.category.cards,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
