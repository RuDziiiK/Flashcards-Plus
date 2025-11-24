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

  // Paleta kolorów dla ikon talii (żeby było kolorowo)
  final List<Color> _deckColors = [
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.tealAccent,
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<Category> loadedCategories = await StorageService.loadCategories();
    setState(() {
      categories = loadedCategories.isNotEmpty ? loadedCategories : globalCategories;
    });
  }

  void _addCategory() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nowa talia"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Nazwa talii",
            hintText: "np. Angielski, Historia...",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Anuluj")),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  categories.add(Category(name: controller.text, cards: []));
                });
                StorageService.saveCategories(categories);
              }
              Navigator.pop(context);
            },
            child: const Text("Utwórz"),
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

      // Używamy CustomScrollView dla efektu "Sliver" (zwijany nagłówek)
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                widget.selectMode ? "Wybierz talię" : "Twoje Talie",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            actions: widget.selectMode ? [] : [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                  onPressed: _addCategory,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
                        ]
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              )
            ],
          ),

          // Jeśli lista pusta
          if (categories.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.layers_clear_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text("Brak talii", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),

          // Siatka kafelków (Grid)
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Dwie kolumny
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85, // Proporcje kafelka (wysokość vs szerokość)
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final cat = categories[index];
                  // Wybierz kolor z palety na podstawie indeksu
                  final color = _deckColors[index % _deckColors.length];

                  return _buildDeckCard(context, cat, color, isDark);
                },
                childCount: categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckCard(BuildContext context, Category cat, Color color, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () async {
            if (widget.selectMode) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LearningScreen(cards: cat.cards)));
            } else {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => FlashcardListScreen(category: cat)));
              _loadData();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Ikona w kolorowym kółku
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.style, color: color, size: 28),
                    ),
                    // Opcjonalnie: Menu opcji (kropki)
                    if (!widget.selectMode)
                      Icon(Icons.more_horiz, color: Colors.grey[400]),
                  ],
                ),

                const Spacer(),

                // 2. Tytuł
                Hero(
                  tag: cat.name,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 3. Licznik kart
                Text(
                  "${cat.cards.length} fiszek",
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                // 4. Pasek postępu (wizualny dodatek)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    // Jeśli są karty, pokaż np. 30% postępu jako zachętę (możesz tu wpiąć prawdziwą logikę)
                    value: cat.cards.isNotEmpty ? 0.3 : 0.0,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                    color: color.withOpacity(0.7),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}