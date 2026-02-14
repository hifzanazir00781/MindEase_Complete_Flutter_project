import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz; // latest_all ki jagah latest behtar hai
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Timezone initialize
    tz.initializeTimeZones();

    // 2. Android Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS Settings
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // --- NEW: Request Permission for Android 13+ ---
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    // Is line se user ko "Allow" ka popup show hoga
  }

  // Instant Notification
  Future<void> showInstantNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'mindease_channel',
      'MindEase Alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      // Sound aur vibration ensure karne ke liye
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // Unique ID use karein taake notifications overwrite na hon
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Scheduled Notification
  Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledTime) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mindease_reminders',
          'MindEase Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}