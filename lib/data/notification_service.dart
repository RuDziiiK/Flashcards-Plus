import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {

  // 1. Inicjalizacja (Uruchamiana w main.dart)
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      // Używamy domyślnej ikony aplikacji ('resource://drawable/res_app_icon')
      // Ale jako fallback dajemy null, wtedy biblioteka poszuka domyślnej
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Przypomnienia o nauce',
          channelDescription: 'Kanał powiadomień dla aplikacji Fiszki',
          defaultColor: Colors.blueAccent,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        )
      ],
      // Logi w konsoli (pomocne przy błędach)
      debug: true,
    );
  }

  // 2. Prośba o uprawnienia
  static Future<bool> requestPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // Wyświetla systemowe okno z prośbą
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    return isAllowed;
  }

  // 3. Planowanie powiadomienia (Codziennie o 18:00)
  static Future<void> scheduleDailyNotification() async {
    // Najpierw usuwamy stare, żeby się nie dublowały
    await cancelNotifications();

    // Tworzymy nowe
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10, // Unikalne ID
        channelKey: 'basic_channel',
        title: 'Czas na naukę! 🎓',
        body: 'Twoje fiszki czekają. Zrób krótką powtórkę.',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: 15,
        minute: 15,
        second: 0,
        millisecond: 0,
        repeats: true, // Powtarzaj codziennie
        allowWhileIdle: true,
      ),
    );
  }

  // 4. Testowe powiadomienie (Natychmiast)
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

  // 5. Anulowanie powiadomień
  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}