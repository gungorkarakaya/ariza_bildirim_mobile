import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
  AndroidNotificationChannel(
    'ariza_bildirim_foreground_channel',
    'Arıza Bildirimleri',
    description: 'Uygulama açıkken gelen arıza bildirimleri',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );

    final androidImplementation =
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(_androidChannel);
  }

  static Future<void> showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;

    final title =
        notification?.title ?? message.data['title'] ?? 'Yeni Arıza Bildirimi';

    final body = notification?.body ??
        message.data['body'] ??
        message.data['message'] ??
        'Yeni bir arıza bildirimi oluşturuldu.';

    const androidDetails = AndroidNotificationDetails(
      'ariza_bildirim_foreground_channel',
      'Arıza Bildirimleri',
      channelDescription: 'Uygulama açıkken gelen arıza bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }
}