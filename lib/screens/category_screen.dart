import 'package:flashcards/data/data.dart';
import 'package:flashcards/screens/learning_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashcards/models/category.dart';
import 'package:flashcards/models/flashcard.dart';
import 'flashcard_list_screen.dart';

class CategoryScreen extends StatefulWidget {
  final bool selectMode;

  const CategoryScreen({super.key, this.selectMode = false});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> categories = globalCategories;

  void _addCategory() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Dodaj kategorię"),
        backgroundColor: Colors.blueAccent,
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nazwa kategorii"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Anuluj"),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  categories.add(
                    Category(name: controller.text, cards: []),
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
        title: Text(widget.selectMode ? "Wybierz kategorię" : "Kategorie fiszek"),
        actions: widget.selectMode
            ? [] // w trybie wyboru nic nie dodajemy
            : [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCategory,
          ),
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
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.white.withOpacity(0.9),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(categories[index].name),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  if (widget.selectMode) {
                    // jeśli tryb wyboru kategorii
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LearningScreen(
                              cards: categories[index].cards,
                            ),
                      ),
                    );
                  } else {
                    // normalny tryb -> przycisk kategorie fiszek
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FlashcardListScreen(category: categories[index]),
                      ),
                    );
                  }
                }
              ),
            );
          },
        ),
      ),
    );
  }
}
