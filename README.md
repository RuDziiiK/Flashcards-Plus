# Flashcards Plus

**Flashcards Plus** to natywna aplikacja mobilna stworzona we Flutterze, wspomagająca proces efektywnego uczenia się metodą powtórek (spaced repetition). Projekt łączy w sobie użyteczność, nowoczesny design (Material Design 3) oraz elementy grywalizacji, które motywują do codziennej nauki.

---

## Funkcjonalności

* **Zarządzanie Taliami (CRUD):** Tworzenie, edycja (zmiana nazwy) oraz usuwanie całych kategorii tematycznych (długie przytrzymanie kafelka).
* **Zarządzanie Fiszkami:** Dodawanie, edycja i usuwanie pojedynczych fiszek wewnątrz talii.
* **Interaktywny Tryb Nauki:** Płynne animacje 3D obracania kart odsłaniające odpowiedź.
* **Śledzenie Postępów:** Możliwość oceny własnej wiedzy (przyciski "Umiem" / "Jeszcze nie"). Aplikacja zapamiętuje opanowane karty i wizualizuje postęp za pomocą wskaźników (np. 5/10 fiszek).
* **Grywalizacja (Profil Użytkownika):** * System poziomów (Level) oparty na liczbie utworzonych kart.
  * Licznik dni nauki z rzędu (Streak), promujący systematyczność.
* **Powiadomienia Lokalne:** Codzienne przypomnienia systemowe zachęcające do nauki.
* **Personalizacja:** Pełne wsparcie dla systemowego trybu ciemnego i jasnego (Dark Mode) z dynamicznym doborem kolorów.

---

## Technologie i Biblioteki

Aplikacja została zbudowana przy użyciu frameworka **Flutter** (wersja >3.0) oraz języka **Dart**. 

Wykorzystane pakiety zewnętrzne (zdefiniowane w `pubspec.yaml`):
* `shared_preferences` - do trwałego zapisu danych (talie, fiszki, profil, ustawienia) w pamięci lokalnej urządzenia.
* `flutter_local_notifications` - do obsługi oraz planowania systemowych powiadomień.
* `google_fonts` - do implementacji nowoczesnej typografii (czcionka *Poppins*).
* `timezone` - do precyzyjnego zarządzania czasem powiadomień.

---

## Architektura Projektu

Projekt korzysta z czytelnego podziału na warstwy, co ułatwia zarządzanie kodem:

```text
lib/
│
├── data/                  # Serwisy i logika biznesowa
│   ├── data.dart                  # Domyślne fiszki
│   ├── notification_service.dart  # Obsługa powiadomień
│   ├── storage_service.dart       # Zapis/odczyt z SharedPreferences
│   └── theme_service.dart         # Zarządzanie trybem Dark/Light
│
├── models/                # Modele danych i serializacja JSON
│   ├── category.dart
│   ├── flashcard.dart
│   └── user_profile.dart
│
├── screens/               # Warstwa widoku (UI)
│   ├── category_screen.dart       # Ekran główny (kafelki talii)
│   ├── flashcard_list_screen.dart # Lista fiszek w talii
│   ├── home_screen.dart           # Pasek nawigacji (BottomNavigationBar)
│   ├── learning_screen.dart       # Tryb nauki z animacjami 3D
│   ├── profile_screen.dart        # Profil, statystyki, grywalizacja
│   ├── settings_screen.dart       # Ustawienia aplikacji
│   └── splash_screen.dart         # Ekran powitalny
│
└── main.dart              # Inicjalizacja aplikacji i konfiguracja motywów (Material 3)
