import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/user_profile.dart';

/// Serwis odpowiedzialny za trwałe zapisywanie danych w pamięci urządzenia.
/// Wykorzystuje bibliotekę SharedPreferences do przechowywania plików JSON.
class StorageService {
  static const String _catKey = 'user_categories';
  static const String _profileKey = 'user_profile';

  // ==========================================
  // SEKCJA: KATEGORIE I FISZKI
  // ==========================================

  /// Pobiera listę kategorii z pamięci urządzenia.
  /// Jeśli brak danych, zwraca pustą listę.
  static Future<List<Category>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    String? encodedData = prefs.getString(_catKey);

    if (encodedData == null) return [];

    // Dekodowanie JSON na listę obiektów
    List<dynamic> decodedList = jsonDecode(encodedData);
    return decodedList.map((item) => Category.fromJson(item)).toList();
  }

  /// Zapisuje całą listę kategorii (wraz z fiszkami) do pamięci.
  static Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    String encodedData = jsonEncode(categories.map((c) => c.toJson()).toList());
    await prefs.setString(_catKey, encodedData);
  }

  // ==========================================
  // SEKCJA: PROFIL UŻYTKOWNIKA I STATYSTYKI
  // ==========================================

  /// Wczytuje profil użytkownika.
  /// Automatycznie wywołuje [_updateStats] aby odświeżyć statystyki (streak, level).
  static Future<UserProfile> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(_profileKey);

    UserProfile profile;
    if (data != null) {
      profile = UserProfile.fromJson(jsonDecode(data));
    } else {
      // Domyślny profil dla nowego użytkownika
      profile = UserProfile(name: "Uczeń", lastStudyDate: "");
    }

    // Aktualizacja statystyk przy każdym uruchomieniu
    await _updateStats(profile);
    return profile;
  }

  /// Zapisuje stan profilu do pamięci.
  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    String data = jsonEncode(profile.toJson());
    await prefs.setString(_profileKey, data);
  }

  /// Wewnętrzna logika aktualizacji statystyk.
  /// Sprawdza "Streak" (dni z rzędu) oraz przelicza łączną liczbę kart.
  static Future<void> _updateStats(UserProfile profile) async {
    List<Category> cats = await loadCategories();
    int total = 0;
    for (var cat in cats) {
      total += cat.cards.length;
    }
    profile.totalCardsCreated = total;

    // 2. Obsługa Streaka (Dni z rzędu)
    DateTime now = DateTime.now();
    String todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // Jeśli data ostatniej nauki jest inna niż dzisiaj
    if (profile.lastStudyDate != todayStr) {
      if (profile.lastStudyDate.isNotEmpty) {
        try {
          DateTime lastDate = DateTime.parse(profile.lastStudyDate);

          // Normalizacja dat (ignorujemy godziny/minuty) dla poprawnego porównania
          DateTime dateNow = DateTime(now.year, now.month, now.day);
          DateTime dateLast = DateTime(lastDate.year, lastDate.month, lastDate.day);

          int difference = dateNow.difference(dateLast).inDays;

          if (difference == 1) {
            profile.studyStreak++;
          } else if (difference > 1) {
            profile.studyStreak = 1;
          }
        } catch (e) {
          profile.studyStreak = 1;
        }
      } else {
        profile.studyStreak = 1;
      }

      profile.lastStudyDate = todayStr;
      await saveUserProfile(profile);
    } else {
      // Nawet jeśli data ta sama, zapisujemy (bo mogła zmienić się liczba kart)
      await saveUserProfile(profile);
    }
  }

  // ==========================================
  // SEKCJA: CZYSZCZENIE DANYCH
  // ==========================================

  /// Usuwa wszystkie dane aplikacji (Reset fabryczny).
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_catKey);
    await prefs.remove(_profileKey);
    await prefs.remove('notifications_enabled');
  }
}