/// Model danych reprezentujący profil użytkownika.
/// Przechowuje statystyki, postępy w nauce oraz elementy grywalizacji (poziom, streak).
class UserProfile {
  /// Wyświetlane imię użytkownika (domyślnie "Uczeń").
  String name;

  /// Łączna liczba kart utworzonych przez użytkownika we wszystkich taliach.
  /// Ta wartość jest podstawą do obliczania poziomu ([level]).
  int totalCardsCreated;

  /// Licznik "Dni z rzędu" (Streak).
  /// Zwiększa się, jeśli użytkownik wchodzi do aplikacji codziennie.
  /// Resetuje się do 1, jeśli użytkownik pominie dzień.
  int studyStreak;

  /// Data ostatniej aktywności w formacie "YYYY-MM-DD".
  /// Służy do sprawdzania, czy użytkownik uczył się dzisiaj lub wczoraj.
  String lastStudyDate;

  UserProfile({
    required this.name,
    this.totalCardsCreated = 0,
    this.studyStreak = 0,
    required this.lastStudyDate,
  });

  // ==========================================
  // LOGIKA GRYWALIZACJI (Gettery)
  // ==========================================

  /// Oblicza aktualny poziom użytkownika na podstawie liczby kart.
  /// Logika: Każde 10 kart daje 1 poziom.
  /// Np. 25 kart = (25 / 10).floor() + 1 = Poziom 3.
  int get level => (totalCardsCreated / 10).floor() + 1;

  /// Oblicza procentowy postęp do następnego poziomu (wartość 0.0 - 1.0).
  /// Używane przez pasek postępu (LinearProgressIndicator) na ekranie profilu.
  /// Np. dla 25 kart: reszta z dzielenia (5) / 10.0 = 0.5 (50% paska).
  double get levelProgress => (totalCardsCreated % 10) / 10.0;

  // ==========================================
  // SERIALIZACJA DANYCH (JSON)
  // ==========================================

  /// Konwertuje profil na format JSON w celu zapisania w pamięci telefonu via [StorageService].
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalCardsCreated': totalCardsCreated,
      'studyStreak': studyStreak,
      'lastStudyDate': lastStudyDate,
    };
  }

  /// Wczytuje profil z formatu JSON.
  /// Zawiera zabezpieczenia (??), które ustawiają wartości domyślne,
  /// jeśli wczytane dane są puste lub uszkodzone (np. przy pierwszym uruchomieniu).
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'Uczeń',
      totalCardsCreated: json['totalCardsCreated'] ?? 0,
      studyStreak: json['studyStreak'] ?? 0,
      lastStudyDate: json['lastStudyDate'] ?? '',
    );
  }
}