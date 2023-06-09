import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'db.helper.dart';
import 'notification_model.dart';

class NotificationPage extends StatefulWidget {
  @override
  _MyNotificationPageState createState() => _MyNotificationPageState();
}

class _MyNotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
  }

  renderTypeNoti(TypoNotificationEnum typeNoti) {
    if (typeNoti == TypoNotificationEnum.AMOUNT) {
      return Center();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(38, 92, 178, 1),
          title: const Text('Mis notificaciones'),
        ),
        body: FutureBuilder<List<NotificationModel>>(
            future: DatabaseHelper.instance.retrieveNotifications(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (BuildContext _context, int index) {
                    final items = snapshot.data?[index];
                    return Dismissible(
                      key: Key(items.toString()),
                      onDismissed: (direction) {
                        DatabaseHelper.instance
                            .deleteNotification(snapshot.data?[index].id ?? 0);
                      },
                      background: Container(
                        color: Colors.red,
                        child: Icon(Icons.delete, color: Colors.white),
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 16.0),
                      ),
                      child: ListTile(
                        title: Text(snapshot.data?[index].title ?? ''),
                        // leading: Text(snapshot.data?[index].id.toString() ?? ''),
                        subtitle: Text(
                          snapshot.data?[index].message ?? '',
                          maxLines: 1,
                        ),
                        onTap: () {
                          context.push(
                              '/push-details/${snapshot.data?[index].id.toString()}');
                        },
                        // trailing: IconButton(
                        //     alignment: Alignment.center,
                        //     icon: Icon(Icons.delete),
                        //     onPressed: () async {
                        //       DatabaseHelper.instance.deleteNotification(
                        //           snapshot.data?[index].id ?? 0);
                        //       setState(() {});
                        //     }),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text("Oops!");
              }
              return Center(child: CircularProgressIndicator());
            }));
  }
}
