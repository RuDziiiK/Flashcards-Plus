/// Model danych reprezentujący pojedynczą fiszkę (kartę do nauki).
/// Przechowuje treść pytania, odpowiedzi oraz aktualny status wiedzy użytkownika.
class Flashcard {
  /// Treść pytania (awers karty).
  final String question;

  /// Treść odpowiedzi (rewers karty).
  final String answer;

  /// Status nauki danej fiszki.
  /// [true] - użytkownik kliknął "Umiem" (zielony przycisk).
  /// [false] - użytkownik kliknął "Jeszcze nie" (czerwony przycisk).
  /// Pole nie jest 'final', ponieważ jego wartość zmienia się w trakcie korzystania z aplikacji.
  bool isMastered;

  Flashcard({
    required this.question,
    required this.answer,
    this.isMastered = false, // Domyślnie nowa fiszka jest traktowana jako "do nauczenia"
  });

  /// Konwertuje obiekt na mapę (format JSON).
  /// Używane przez [StorageService] do zapisania stanu fiszki (w tym postępu nauki) w pamięci telefonu.
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'isMastered': isMastered, // Zapisujemy, czy użytkownik już umie tę kartę
    };
  }

  /// Tworzy obiekt [Flashcard] na podstawie danych z JSON.
  /// Używane przy wczytywaniu zapisanych talii.
  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      question: json['question'],
      answer: json['answer'],
      // Operator '??' (null-coalescing) zapewnia bezpieczeństwo:
      // Jeśli w starych danych nie było pola 'isMastered', przyjmujemy domyślnie 'false'.
      isMastered: json['isMastered'] ?? false,
    );
  }
}