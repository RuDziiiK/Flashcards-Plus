import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

/// Serwis odpowiedzialny za zarządzanie powiadomieniami lokalnymi.
/// Wykorzystuje bibliotekę 'awesome_notifications' do planowania i wyświetlania komunikatów.
class NotificationService {

  /// Inicjalizuje konfigurację powiadomień.
  /// Musi zostać wywołana w [main.dart] przed uruchomieniem aplikacji.
  /// Tworzy kanał powiadomień (wymagany przez Android 8.0+).
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      // null oznacza użycie domyślnej ikony aplikacji z AndroidManifest
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Przypomnienia o nauce',
          channelDescription: 'Kanał powiadomień dla aplikacji Fiszki',
          defaultColor: Colors.blueAccent,
          ledColor: Colors.white,
          importance: NotificationImportance.High, // Powiadomienie wyda dźwięk i wibrację
          channelShowBadge: true,
        )
      ],
      // Tryb debugowania: wypisuje logi w konsoli (pomocne przy deweloperce)
      debug: true,
    );
  }

  /// Sprawdza status uprawnień i prosi użytkownika o zgodę, jeśli jest wymagana.
  /// Kluczowe dla Androida 13+, gdzie uprawnienia nie są nadawane automatycznie.
  /// Zwraca [true], jeśli użytkownik wyraził zgodę.
  static Future<bool> requestPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    if (!isAllowed) {
      // Wyświetla systemowe okno dialogowe z prośbą o uprawnienia
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    return isAllowed;
  }

  /// Planuje cykliczne powiadomienie przypominające o nauce.
  /// Domyślna godzina: 18:00 każdego dnia.
  static Future<void> scheduleDailyNotification() async {
    // Dobrą praktyką jest usunięcie starych harmonogramów przed dodaniem nowego,
    // aby uniknąć duplikowania powiadomień.
    await cancelNotifications();

    // Tworzenie nowego harmonogramu
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10, // Stałe ID pozwala nadpisać to powiadomienie w przyszłości
        channelKey: 'basic_channel',
        title: 'Czas na naukę! 🎓',
        body: 'Twoje fiszki czekają. Zrób krótką powtórkę.',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: 18,
        minute: 0,
        second: 0,
        millisecond: 0,
        repeats: true, // Kluczowe: powtarzaj codziennie o tej samej porze
        allowWhileIdle: true, // Wyświetl nawet, gdy telefon jest w trybie uśpienia
      ),
    );
  }

  /// Wyświetla natychmiastowe powiadomienie testowe.
  /// Służy do potwierdzenia użytkownikowi, że funkcja została włączona.
  static Future<void> showInstantNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 11,
        channelKey: 'basic_channel',
        title: 'Powiadomienia aktywne ✅',
        body: 'Będziemy Ci przypominać o nauce codziennie o 18:00.',
      ),
    );
  }

  /// Anuluje wszystkie aktywne i zaplanowane powiadomienia.
  /// Używane przy wyłączaniu funkcji w ustawieniach lub resetowaniu aplikacji.
  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}