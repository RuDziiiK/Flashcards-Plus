import 'dart:convert'; // Potrzebne do jsonEncode i jsonDecode
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

class StorageService {
  static const String _key = 'user_categories';

  // Zapisywanie listy kategorii
  static Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Zamieniamy każdą kategorię na JSON (Mapę)
    // 2. Kodujemy listę map do formatu String
    String encodedData = jsonEncode(
      categories.map((c) => c.toJson()).toList(),
    );

    // 3. Zapisujemy String w pamięci telefonu
    await prefs.setString(_key, encodedData);
  }

  // Wczytywanie listy kategorii
  static Future<List<Category>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Pobieramy zapisany String
    String? encodedData = prefs.getString(_key);

    if (encodedData == null) {
      return []; // Jeśli nic nie ma, zwracamy pustą listę
    }

    // 2. Dekodujemy String na listę obiektów dynamicznych
    List<dynamic> decodedList = jsonDecode(encodedData);

    // 3. Zamieniamy każdy element z powrotem na obiekt Category
    return decodedList.map((item) => Category.fromJson(item)).toList();
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key); // Usuwa zapisane kategorie
  }
}