import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsServices {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final StreamController<NotificationResponse> streamController =
      StreamController<NotificationResponse>.broadcast();
  static onTap(NotificationResponse notificationResponse) {
    streamController.add(notificationResponse);
  }

  static Future<void> init() async {
    InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: DarwinInitializationSettings(),
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: onTap,
      onDidReceiveNotificationResponse: onTap,
    );
  }

static Future<bool> requestNotificationPermission() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final bool? isGranted = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  
  // رجع true لو اتقبل، false لو لا (أو null، هنعاملها زي false)
  return isGranted ?? false;
}
  static Future<void> showBasicNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final bool? isGranted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    if (isGranted == true) {
    } else {
      requestNotificationPermission();
    }

    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        "channel_id",
        "channel_name",
        importance: Importance.high,
        priority: Priority.high,
        channelShowBadge: true,
        enableLights: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
      ),
    );
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: 'Default_Sound',
    );
  }
}
