import 'package:flashcards/data/data.dart';
import 'package:flashcards/screens/learning_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashcards/models/category.dart';
import 'package:flashcards/models/flashcard.dart';
import 'flashcard_list_screen.dart';
import 'package:flashcards/data/storage_service.dart';

class CategoryScreen extends StatefulWidget {
  final bool selectMode;

  const CategoryScreen({super.key, this.selectMode = false});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<Category> loadedCategories = await StorageService.loadCategories();
    setState(() {
      if (loadedCategories.isNotEmpty) {
        categories = loadedCategories;
      } else {
        categories = globalCategories;
      }
    });
  }

  void _addCategory() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Dodaj kategorię"),
        // Kolor tła dialogu też warto uzależnić od motywu, ale zostawmy domyślny
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nazwa kategorii"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Anuluj")),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  categories.add(Category(name: controller.text, cards: []));
                });
                StorageService.saveCategories(categories);
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
    // 1. SPRAWDZAMY: Czy aplikacja jest w trybie ciemnym?
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectMode ? "Wybierz kategorię" : "Kategorie fiszek"),
        actions: widget.selectMode
            ? []
            : [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCategory,
          ),
        ],
      ),
      body: Container(
        // 2. DYNAMICZNE TŁO: Jeśli ciemno -> szary gradient, jeśli jasno -> niebieski
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2C3E50), const Color(0xFF000000)] // Ciemny motyw
                : [Colors.blueAccent, Colors.lightBlueAccent],       // Jasny motyw
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return Card(
              // 3. DYNAMICZNY KOLOR KARTY
              color: isDark ? Colors.grey[800] : Colors.white.withOpacity(0.9),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  categories[index].name,
                  // 4. DYNAMICZNY KOLOR TEKSTU (żeby był czytelny na ciemnej karcie)
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: isDark ? Colors.white70 : Colors.black54
                ),
                onTap: () async {
                  if (widget.selectMode) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LearningScreen(cards: categories[index].cards),
                      ),
                    );
                  } else {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashcardListScreen(category: categories[index]),
                      ),
                    );
                    _loadData();
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}