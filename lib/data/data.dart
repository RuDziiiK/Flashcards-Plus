import '../models/category.dart';
import '../models/flashcard.dart';

List<Category> globalCategories = [
  Category(
    name: "Słówka angielskie",
    cards: [
      Flashcard(question: "Hello", answer: "Cześć"),
      Flashcard(question: "Dog", answer: "Pies"),
    ],
  ),
  Category(
    name: "Matematyka — wzory",
    cards: [
      Flashcard(question: "Pole koła", answer: "πr²"),
      Flashcard(question: "Prędkość", answer: "v = s / t"),
    ],
  ),
  Category(
    name: "Chemia — reakcje",
    cards: [
      Flashcard(
        question: "Spalanie metanu",
        answer: "CH₄ + 2O₂ → CO₂ + 2H₂O",
      ),
    ],
  ),
];
