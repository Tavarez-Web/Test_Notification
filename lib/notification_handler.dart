import 'package:flutter/material.dart';

// Clase para representar los datos de una notificación
class NotificationData {
  final String title;
  final String body;
  final String imageUrl;

  NotificationData({
    required this.title,
    required this.body,
    required this.imageUrl,
  });
}

// Clase para manejar las notificaciones
class NotificationHandler {
  List<NotificationData> notifications = [];

  void addNotification(NotificationData notification) {
    notifications.add(notification);
  }

  void clearNotifications() {
    notifications.clear();
  }
}
