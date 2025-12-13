import 'package:wesal/logic/services/notifications/fcm_notification.dart';
import 'package:wesal/logic/services/notifications/local_notifications_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  getIt.registerLazySingleton(() => NotificationsHelper());
  getIt.registerLazySingleton(() => FirebaseMessaging.instance);
  getIt.registerLazySingleton(() => LocalNotificationsServices());
}
