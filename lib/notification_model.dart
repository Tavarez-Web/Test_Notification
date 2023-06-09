
import 'dart:math';
import 'dart:convert';
import 'dart:ffi';

enum TypoNotificationEnum { AMOUNT, HEAL, BHD, PROMOTION }

class TypeNotification {
  late int? amounts_list_id;
  late String? name;
  late String? value;
  late String? type = '';

  TypeNotification({this.amounts_list_id, this.name, this.value, this.type});
  Map<String, dynamic> toMap() {
    return {
      'amounts_list_id': amounts_list_id,
      'name': name,
      'value': value,
      'type': type,
    };
  }

  factory TypeNotification.fromJSON(Map json) {
    return TypeNotification(
      amounts_list_id: json['amounts_list_id'],
      name: json['name'],
      value: json['value'],
      type: json['type'],
    );
  }
}

class NotificationModel {
  late int id;
  late String? subject;
  late String? title;
  late String? type;
  String? imageUrl = '';
  late String? message;
  late String? data;

  // late Array? [] ;
  static const String TABLENAME = "Notification";
  static const String SUB_TABLENAME = 'Amount';

  NotificationModel(
      {this.id = 0,
      this.subject,
      this.title,
      this.type,
      this.message,
      this.imageUrl,
      this.data});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'title': title,
      'type': type,
      'imageUrl': imageUrl,
      'message': message,
      'data': data
    };
  }

  factory NotificationModel.fromJSON(Map json) {
    return NotificationModel(
      id: json['id'],
      subject: json['subject'],
      title: json['title'],
      type: json['type'],
      imageUrl: json['imageUrl'],
      message: json['message'],
    );
  }

  factory NotificationModel.fromJsonNotification(dynamic json) {
    var data = json['default'];
    var subData = jsonDecode(data);
    var list = subData['data'];

    return NotificationModel(
        id: subData['message'].hashCode ,
        subject: subData['subject'],
        title: subData['title'],
        type: subData['type'],
        imageUrl: subData['imageUrl'] ?? '',
        message: subData['message'],
        data: list.toString());
  }

  factory NotificationModel.fromJsonNotificationV2(dynamic json) {
    var subData = json;

   
    var list = subData['data'];

    print('montos ${list.toString()}');

    return NotificationModel(
      id: subData['id'],
      subject: subData['subject'],
      title: subData['title'],
      type: subData['type'],
      imageUrl: subData['imageUrl'] ?? '',
      message: subData['message'],
      data: list.toString(),
    );
  }
}
