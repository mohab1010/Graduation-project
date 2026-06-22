import 'package:wesal/logic/cubit/add_child/cubit/children_cubit.dart';
import 'package:wesal/logic/services/di/dependancy_injection.dart';
import 'package:wesal/logic/services/notifications/fcm_notification.dart';
import 'package:wesal/logic/services/notifications/local_notifications_services.dart';
import 'package:wesal/logic/services/sized_config.dart';
import 'package:wesal/presentation/screens/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'firebase_options.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Supabase.initialize(
    url: "https://phhqpmglrxjpfyieoncf.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoaHFwbWdscnhqcGZ5aWVvbmNmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0ODU0NDEsImV4cCI6MjA5NDA2MTQ0MX0.4F7VvuNO7LCNvK8jAvbiypGIJ1G8XsV2fL2H779aFHw",
);
  await setupDI();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await getIt<NotificationsHelper>().initNotifications();
  getIt<NotificationsHelper>().setupFirebaseMessaging();
  final bool permissionGranted =
      await LocalNotificationsServices.requestNotificationPermission();
  if (!permissionGranted) {
    SystemNavigator.pop();
    return;
  }
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
  await ZegoUIKit().initLog().then((value) async {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI([
      ZegoUIKitSignalingPlugin(),
    ]);
    runApp(
      BlocProvider(create: (context) => ChildrenCubit(), child: const MyApp()),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return MaterialApp(
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: Colors.black,
        ),
      ),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
