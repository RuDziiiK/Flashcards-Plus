class Flashcard {
  final String question;
  final String answer;

  Flashcard({required this.question, required this.answer});

  // Zamiana obiektu na mapę (do zapisu JSON)
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
    };
  }

  // Tworzenie obiektu z mapy (odczyt z JSON)
  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      question: json['question'],
      answer: json['answer'],
    );
  }
}