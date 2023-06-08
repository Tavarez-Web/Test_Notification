// import 'dart:convert';

// class NotificationModel {
//   late int? id;
//   late String? title;
//   late String? message;
//   late String? imageURL;
//   late String? action;
//   static const String TABLENAME = "Notification";

//   NotificationModel(
//       {this.id, this.title, this.message, this.imageURL, this.action});

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'title': title,
//       'message': message,
//       'imageURL': imageURL,
//       'action': action
//     };
//   }

//   factory NotificationModel.fromJSON(Map json) {
//     return NotificationModel(
//         action: json['action'],
//         id: json['id'],
//         imageURL: json['imageURL'],
//         message: json['message'],
//         title: json['title']);
//   }

//   factory NotificationModel.fromJsonNotification(dynamic json) {
//     var data = json['default'];
//     var sub_data = jsonDecode(data)['data'];
//     return NotificationModel(
//         action: sub_data['action'],
//         id: sub_data['message'].hashCode,
//         imageURL: sub_data['imageURL'],
//         message: sub_data['message'],
//         title: sub_data['title']);
//   }
// }

import 'dart:convert';
import 'dart:ffi';

enum TypoNotificationEnum { AMOUNT, HEAL, BHD, PROMOTION }

class TypeNotification {
  late int?  amounts_list_id;
  late String? name;
  late String? value;
  late String? type = '';

    TypeNotification(
      {
        this.amounts_list_id,
        this.name,
        this.value,
        this.type
      }
    );
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
  late int? id;
  late String? subject;
  late String? title;
  late String? type;
   String imageUrl = '';
  late String? message;
  late List<dynamic>? data;

  // late Array? [] ;
  static const String TABLENAME = "Notification";
  static const String SUB_TABLENAME = 'Amount';

  NotificationModel(
      {this.id,
      this.subject,
      this.title,
      this.type,
      this.message,
      this.imageUrl = '',
      this.data});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'title': title,
      'type': type,
      'imageUrl': imageUrl,
      'message': message,
      // 'data': data
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
    var sub_data = jsonDecode(data);
    var list_amount = sub_data['data'] as List<dynamic>;
    print(list_amount as List<dynamic>);
    return NotificationModel(
        id: sub_data['message'].hashCode,
        subject: sub_data['subject'],
        title: sub_data['title'],
        type: sub_data['type'],
        imageUrl: sub_data['imageUrl'] ?? '',
        message: sub_data['message'],
        data: list_amount);
  }
}
