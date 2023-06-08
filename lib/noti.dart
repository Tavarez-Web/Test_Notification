// import 'dart:developer';
// import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';

// import 'config/router/app_router.dart';
// import 'db.helper.dart';
// import 'notification_model.dart';

// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   Map<String, dynamic> snsMessage = message.data;
//   var _snsMessage = NotificationModel.fromJsonNotification(snsMessage);
//   if (flutterLocalNotificationsPlugin == null) {
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   }
//   if (_snsMessage.imageUrl != null &&
//       _snsMessage.imageUrl != null) {
//     log("h2");
//     return NotificationHandler().showBigPictureNotification(message);
//   } else if (snsMessage["pinpoint.notification.imageUrl"] != null) {
//     return NotificationHandler()
//         .showBigPictureNotificationHiddenLargeIcon(snsMessage);
//   } else
//     flutterLocalNotificationsPlugin.show(
//         _snsMessage.message.hashCode,
//         _snsMessage.title,
//         _snsMessage.message,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             'high_importance_channel', // id
//             'High Importance Notifications', // title
//             channelDescription:
//                 'This channel is used for important notifications.',
//             // description
//             importance: Importance.high,
//             icon: null, // android?.smallIcon,
//             // other properties...
//           ),
//           iOS: DarwinNotificationDetails(
//             presentAlert: true,
//             presentBadge: true,
//             presentSound: true,
//             subtitle: _snsMessage.title,
//             sound: "default",
//             threadIdentifier:
//                 _snsMessage.message.hashCode.toString(),
//           ),
//         ));
//   await DatabaseHelper.instance.initializeDatabase();
//   DatabaseHelper.instance.insertNotification(_snsMessage);
// }

// class NotificationHandler {
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//   late AndroidNotificationChannel channel;

//   NotificationHandler() {
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//     // if (!kIsWeb) {
//     channel = const AndroidNotificationChannel(
//       'high_importance_channel', // id
//       'High Importance Notifications', // title
//       description: 'This channel is used for important notifications.',
//       // description
//       importance: Importance.high,
//     );
//     var initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: DarwinInitializationSettings(
//           requestAlertPermission: true,
//           requestBadgePermission: true,
//           requestSoundPermission: true,
//           onDidReceiveLocalNotification:
//               (int id, String? title, String? body, String? payload) async {
//             log("onDidReceiveLocalNotification $id $title $body $payload");
//           }),
//     );
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onDidReceiveNotificationResponse:
//             NotificationHandler.onDidReceiveNotificationResponse);

//     /// Create an Android Notification Channel.
//     ///
//     /// We use this channel in the `AndroidManifest.xml` file to override the
//     /// default FCM channel to enable heads up notifications.
//     flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);

//     flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
//         IOSFlutterLocalNotificationsPlugin>();

//     FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     getToken();
//   }

//   Future<void> getToken() async {
//     var token = await FirebaseMessaging.instance.getToken();
//     log("token =$token");
//   }

//   Future<void> firebaseMessagingForegroundHandler(RemoteMessage message) {
//     Map<String, dynamic> snsMessage = message.data;
//   var _snsMessage = NotificationModel.fromJsonNotification(snsMessage);

//     if (_snsMessage.imageUrl != null &&
//         _snsMessage.imageUrl != null) {
//       return showBigPictureNotification(message);
//     } else if (_snsMessage.imageUrl != null) {
//       return showBigPictureNotificationHiddenLargeIcon(snsMessage);
//     } else {
//       return flutterLocalNotificationsPlugin.show(
//         _snsMessage.message.hashCode,
//         _snsMessage.title,
//         _snsMessage.message,
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'high_importance_channel', // id
//             'High Importance Notifications', // title
//             channelDescription:
//                 'This channel is used for important notifications.',
//             // descriptio
//             importance: Importance.high,
//             icon: null,
//           ),
//           iOS: DarwinNotificationDetails(
//             presentAlert: true,
//             presentBadge: true,
//             presentSound: true,
//           ),
//         ),
//       );
//     }
//   }

//   Future<void> showBigPictureNotification(RemoteMessage message) async {
//     Map<String, dynamic> snsMessage = message.data;
//      var _snsMessage = NotificationModel.fromJsonNotification(snsMessage);
//     final String largeIconPath = await _downloadAndSaveFile(
//         _snsMessage.imageUrl, 'largeIcon');
//     final String bigPicturePath = await _downloadAndSaveFile(
//         _snsMessage.imageUrl, 'bigPicture');
//     final BigPictureStyleInformation bigPictureStyleInformation =
//         BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
//             largeIcon: FilePathAndroidBitmap(largeIconPath),
//             contentTitle:
//                 '<b>${_snsMessage.title}</b>',
//             htmlFormatContentTitle: true,
//             summaryText: '${_snsMessage.message}',
//             htmlFormatSummaryText: true);
//     final AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//             'big text channel id', 'big text channel name',
//             channelDescription: 'big text channel description',
//             styleInformation: bigPictureStyleInformation);
//     final NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//     await flutterLocalNotificationsPlugin.show(
//         _snsMessage.id.hashCode,
//         _snsMessage.title,
//         _snsMessage.message,
//         platformChannelSpecifics);
//   }

//   Future<void> showBigPictureNotificationHiddenLargeIcon(
//       Map<String, dynamic> pinpointMessage) async {
//     final String bigPicturePath = await _downloadAndSaveFile(
//         pinpointMessage["pinpoint.notification.imageUrl"], 'bigPicture');
//     final BigPictureStyleInformation bigPictureStyleInformation =
//         BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
//             hideExpandedLargeIcon: true,
//             contentTitle:
//                 '<b>${pinpointMessage["pinpoint.notification.title"]}</b>',
//             htmlFormatContentTitle: true,
//             summaryText: '${pinpointMessage["pinpoint.notification.body"]}',
//             htmlFormatSummaryText: true);
//     final AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//             'big text channel id', 'big text channel name',
//             channelDescription: 'big text channel description',
//             styleInformation: bigPictureStyleInformation);
//     final NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//     await flutterLocalNotificationsPlugin.show(
//         pinpointMessage["pinpoint.campaign.campaign_id"].hashCode,
//         pinpointMessage["pinpoint.notification.title"],
//         pinpointMessage["pinpoint.notification.body"],
//         platformChannelSpecifics);
//   }

//   Future<String> _downloadAndSaveFile(String url, String fileName) async {
//     final Directory directory = await getApplicationDocumentsDirectory();
//     final String filePath = '${directory.path}/$fileName';
//     if ( url.isEmpty) return '';
//     final http.Response response = await http.get(Uri.parse(url));
//     final File file = File(filePath);
//     await file.writeAsBytes(response.bodyBytes);
//     return filePath;
//   }

//   static void onDidReceiveNotificationResponse(NotificationResponse response) {
//     print(response.id);
  
//     appRouter.push('/push-details/${response.id.toString()}');
//   }
// }


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
  if (flutterLocalNotificationsPlugin == null) {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }
  if (_data.imageUrl != null &&
      _data.imageUrl != null) {
    log("h2");
    print("la _data${_data.message}");
    return NotificationHandler().showBigPictureNotification(message);
  } else if (_data.imageUrl != null) {
    return NotificationHandler()
        .showBigPictureNotificationHiddenLargeIcon(message);
  } else
   await flutterLocalNotificationsPlugin.show(
        _data.message.hashCode,
        _data.title,
        _data.message,
        NotificationDetails(
          android: AndroidNotificationDetails(
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
            subtitle: _data.title,
            sound: "default",
            threadIdentifier:
                _data.message.hashCode.toString(),
          ),
        ));
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

    await flutterLocalNotificationsPlugin.show(
        _data.message.hashCode,
        _data.title,
        _data.message,
        platformChannelSpecifics,
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


  Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
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
          message.data!["image"] as String,
          message.data!["title"] as String)),
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