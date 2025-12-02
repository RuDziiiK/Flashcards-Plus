import 'flashcard.dart';

class Category {
  final String name;
  final List<Flashcard> cards;

  Category({required this.name, required this.cards});

  // Zamiana kategorii (wraz z listą fiszek) na JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cards': cards.map((card) => card.toJson()).toList(),
    };
  }

  // Odczyt kategorii z JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    var list = json['cards'] as List;
    List<Flashcard> cardsList = list.map((i) => Flashcard.fromJson(i)).toList();

    return Category(
      name: json['name'],
      cards: cardsList,
    );
  }
}