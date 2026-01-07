import 'flashcard.dart';

/// Model danych reprezentujący pojedynczą kategorię (talię) fiszek.
/// Przechowuje nazwę talii oraz listę przypisanych do niej kart.
class Category {
  /// Nazwa kategorii (np. "Język Angielski", "Matematyka").
  final String name;

  /// Lista obiektów [Flashcard] należących do tej kategorii.
  final List<Flashcard> cards;

  Category({required this.name, required this.cards});

  /// Konwertuje obiekt [Category] na mapę (format JSON).
  /// Jest to niezbędne do zapisania obiektu w pamięci telefonu (SharedPreferences),
  /// ponieważ nie można zapisać złożonych obiektów bezpośrednio, trzeba je zamienić na tekst/mapę.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      // Mapujemy każdą fiszkę z listy na jej reprezentację JSON, aby zapisać całą strukturę
      'cards': cards.map((card) => card.toJson()).toList(),
    };
  }

  /// Tworzy obiekt [Category] na podstawie mapy JSON.
  /// Używane przy odczytywaniu zapisanych danych z pamięci telefonu.
  /// Odtwarza strukturę obiektową z surowych danych.
  factory Category.fromJson(Map<String, dynamic> json) {
    // 1. Pobieramy listę surowych danych JSON dla kart
    var list = json['cards'] as List;

    // 2. Zamieniamy każdy element listy JSON z powrotem na obiekt Flashcard
    List<Flashcard> cardsList = list.map((i) => Flashcard.fromJson(i)).toList();

    return Category(
      name: json['name'],
      cards: cardsList,
    );
  }
}