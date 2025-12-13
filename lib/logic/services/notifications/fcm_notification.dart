import 'dart:convert';
import 'dart:developer';
import 'package:wesal/logic/services/notifications/local_notifications_services.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/services.dart' show rootBundle;

class NotificationsHelper {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.max,
  );

  // initialize firebase and local notifications
  Future<void> initNotifications() async {
    NotificationSettings settings =
        await _firebaseMessaging.getNotificationSettings();
    await LocalNotificationsServices.init();
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // local notifications init
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // create notification channel explicitly
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // get device token
    String? deviceToken = await _firebaseMessaging.getToken();
    print("Device Token: $deviceToken");
  }

  void setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        log(message.notification!.title.toString());
        LocalNotificationsServices.showBasicNotification(
          body: message.notification!.body.toString(),
          title: message.notification!.title.toString(),
          id: 1,
        );
      }
    });
  }

  // get access token for firebase messaging
  Future<String?> getAccessToken() async {
    try {
      String jsonString =
          await rootBundle.loadString('assets/service-account.json');
      final serviceAccountJson = jsonDecode(jsonString);

      List<String> scopes = [
        "https://www.googleapis.com/auth/firebase.messaging",
      ];

      var client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
      );

      var credentials = await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client,
      );

      client.close();
      return credentials.accessToken.data;
    } catch (e) {
      print("Error getting access token: $e");
      return null;
    }
  }

  // body for sending to topic
  Map<String, dynamic> getTopicBody({
    required String topic,
    required String title,
    required String body,
    String? type,
  }) {
    return {
      "message": {
        "topic": topic,
        "notification": {"title": title, "body": body},
        "android": {
          "notification": {
            "sound": "default",
            "channel_id": "high_importance_channel",
            "notification_priority": "PRIORITY_MAX"
          }
        },
        "apns": {
          "payload": {
            "aps": {"content_available": true}
          }
        },
        "data": {
          "type": type ?? "message",
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
        }
      }
    };
  }

  // body for sending to token
  Map<String, dynamic> getTokenBody({
    required String token,
    required String title,
    required String body,
    String? type,
  }) {
    return {
      "message": {
        "token": token,
        "notification": {"title": title, "body": body},
        "android": {
          "notification": {
            "sound": "default",
            "channel_id": "high_importance_channel",
            "notification_priority": "PRIORITY_MAX"
          }
        },
        "apns": {
          "payload": {
            "aps": {"content_available": true}
          }
        },
        "data": {
          "type": type ?? "message",
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
        }
      }
    };
  }

  // send notification to token or topic
  Future<void> sendNotification({
    String? topic,
    String? token,
    required String title,
    required String body,
    String? type,
  }) async {
    try {
      if (topic == null && token == null) {
        throw Exception("You must provide either topic or token.");
      }

      String? accessToken = await getAccessToken();

      const String url =
          "https://fcm.googleapis.com/v1/projects/wesal-6a246/messages:send";

      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer $accessToken';

      var requestBody = topic != null
          ? getTopicBody(topic: topic, title: title, body: body, type: type)
          : getTokenBody(token: token!, title: title, body: body, type: type);

      var response = await dio.post(url, data: requestBody);

      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      log(topic ?? token!);
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  // subscribe to topic
  Future<void> subscribeToTopic({required String topic}) async {
    log('Subscribed to $topic');
    await _firebaseMessaging.requestPermission();
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // unsubscribe from topic
  Future<void> unSubscribeToTopic({required String topic}) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
