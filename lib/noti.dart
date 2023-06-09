import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'config/router/app_router.dart';
import 'db.helper.dart';
import 'notification_model.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  var data = message.data;
  var _data = NotificationModel.fromJsonNotification(data);
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'high_importance_channel', // id
    'Notificaciones de alta importancia', // título
    // description: 'Este canal se utiliza para notificaciones importantes.',
    // descripción
    importance: Importance.high,
    icon: null, // android?.smallIcon,
    // otras propiedades...
  );
  var iOSPlatformChannelSpecifics = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    subtitle: _data.title,
    sound: "default",
    threadIdentifier: _data.id.toString(),
  );
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(_data.id,
      _data.title, _data.message, platformChannelSpecifics,
      payload: jsonEncode(message.data));

  await DatabaseHelper.instance.initializeDatabase();
  DatabaseHelper.instance.insertNotification(_data);
}

class NotificationHandler {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannel channel;

  NotificationHandler() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'Notificaciones de alta importancia', // título
      description: 'Este canal se utiliza para notificaciones importantes.',
      // descripción
      importance: Importance.high,
    );
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          onDidReceiveLocalNotification:
              (int? id,  String? title, String? body, String? payload) async {
            log("onDidReceiveLocalNotification $id $title $body $payload");
          }),
    );
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            NotificationHandler.onDidReceiveNotificationResponse);

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    getToken();
  }

  Future<void> getToken() async {
    var token = await FirebaseMessaging.instance.getToken();
    log("token =$token");
  }

  Future<dynamic> firebaseMessagingForegroundHandler(
      RemoteMessage message) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var data = message.data;
    var _data = NotificationModel.fromJsonNotification(data);

    await DatabaseHelper.instance.initializeDatabase();
    DatabaseHelper.instance.insertNotification(_data);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel', // id
      'Notificaciones de alta importancia', // título
      // description: 'Este canal se utiliza para notificaciones importantes.',
      // descripción
      importance: Importance.high,
      icon: null, // android?.smallIcon,
      // otras propiedades...
    );
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: _data.title,
      sound: "default",
      threadIdentifier: _data.id.toString(),
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(_data.id,
        _data.title, _data.message, platformChannelSpecifics,
        payload: jsonEncode(message.data));
  }

  Future<void> showBigPictureNotification(RemoteMessage message) async {
    var image = message.data?["image"] as String?;
    var title = message.data?["title"] as String?;

    if (image != null && title != null) {
      var filePath = await _downloadAndSaveFile(image, title);
      var bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(filePath),
      );
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'big_picture_channel', 'Notificaciones con imágenes grandes',
          channelDescription:
              'Este canal se utiliza para notificaciones con imágenes grandes.',
          styleInformation: bigPictureStyleInformation);
      var platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        title.hashCode,
        title,
        message.data!["message"] as String,
        platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );
    }
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> showBigPictureNotificationHiddenLargeIcon(
      RemoteMessage message) async {
    var bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(await _downloadAndSaveFile(
          message.data!["image"] as String, message.data!["title"] as String)),
      hideExpandedLargeIcon: true,
    );
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'big_picture_channel_hidden_large_icon',
        'Notificaciones con imágenes grandes (icono grande oculto)',
        channelDescription:
            'Este canal se utiliza para notificaciones con imágenes grandes donde el icono grande está oculto.',
        styleInformation: bigPictureStyleInformation);
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      message.data!["message"].hashCode,
      message.data!["title"] as String,
      message.data!["message"] as String,
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  static void onDidReceiveNotificationResponse(NotificationResponse response) {
    print("ID NOTIIIIII${response.id}");
    appRouter.push('/push-details/${response.id.toString()}');
  }
}
