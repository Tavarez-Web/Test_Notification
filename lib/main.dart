import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:test_notification/config/router/app_router.dart';
import 'db.helper.dart';
import 'noti.dart';
import 'notification_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  NotificationHandler? _notificationHandler = NotificationHandler();
  await DatabaseHelper.instance.initializeDatabase();

  try {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    // print(e);
  }
  await FirebaseMessaging.instance.subscribeToTopic('general');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    Map<String, dynamic> _default = message.data;

    print(_default);

    DatabaseHelper.instance.insertNotification( NotificationModel.fromJsonNotification(_default));
    if (message.data.isNotEmpty) {
      _notificationHandler.firebaseMessagingForegroundHandler(message);
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      title: 'Material App',
      // home: HomePage(),
    );
  }
}
