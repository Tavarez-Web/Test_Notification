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
  var messageData = message.data;
  var data = NotificationModel.fromJsonNotification(messageData);

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  if (data.imageUrl != null && data.imageUrl != null) {
    log("h2");
    // print("la _data${data.message}");
    return NotificationHandler().showBigPictureNotification(message);
  } else if (data.imageUrl != null) {
    return NotificationHandler()
        .showBigPictureNotificationHiddenLargeIcon(message);
  } else {
    await flutterLocalNotificationsPlugin.show(
        data.id,
        data.title,
        data.message,
        NotificationDetails(
          android: const AndroidNotificationDetails(
            'high_importance_channel', // id
            'Notificaciones de alta importancia', // título
            channelDescription:
                'Este canal se utiliza para notificaciones importantes.',
            // descripción
            importance: Importance.high,
            icon: null, // android?.smallIcon,
            // otras propiedades...
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            subtitle: data.title,
            sound: "default",
            threadIdentifier: data.id.toString(),
          ),
        ));
    await DatabaseHelper.instance.initializeDatabase();
    DatabaseHelper.instance.insertNotification(data);
  }
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

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    // }
  }

  Future<dynamic> firebaseMessagingForegroundHandler(
      RemoteMessage message) async {
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
      threadIdentifier: _data.message.hashCode.toString(),
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(_data.message.hashCode,
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
      message.data!["title"].hashCode,
      message.data!["title"] as String,
      message.data!["message"] as String,
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  static void onDidReceiveNotificationResponse(NotificationResponse response) {
    print(response.id);
    appRouter.push('/push-details/${response.id.toString()}');
  }
}
