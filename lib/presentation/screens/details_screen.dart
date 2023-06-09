import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_notification/config/router/app_router.dart';

import '../../db.helper.dart';
import '../../notification_model.dart';

class DetailScreen extends StatefulWidget {
  final String pushMessaheId;

  const DetailScreen({Key? key, required this.pushMessaheId}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  NotificationModel? notificationModel;
  List<TypeNotification> dataNotification = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    var notification = await DatabaseHelper.instance
        .getNotificationById(int.parse(widget.pushMessaheId));

    setState(() {
      notificationModel = notification;
      dataNotification = extractDataFromModel(notification);
    });
  }

  List<TypeNotification> extractDataFromModel(NotificationModel? model) {
    if (model == null) return [];

    String data = model.data ?? "";
    String arrayString = jsonEncode(data);
    List<String> arrayItems = arrayString.split(', ');

    return arrayItems
        .map((item) {
          List<String> keyValue = item.split(': ');
          if (keyValue.length >= 2) {
            String name = keyValue[0]
                .trim()
                .replaceAll('{', '')
                .replaceAll('[', '')
                .replaceAll('"', '');

            String value =
                keyValue[1].replaceAll('}', '').replaceAll(']\"', '');

            name = name
                .replaceAll("name", "\"name\"")
                .replaceAll("value", "\"value\"");

            return TypeNotification(name: name, value: value);
          }
        })
        .where((element) => element != null)
        .cast<TypeNotification>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(38, 92, 178, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            appRouter.pop(context);
          },
        ),
        title: Text(notificationModel?.subject ?? 'Detalles'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notificationModel != null) ...[
                if (notificationModel!.imageUrl != null &&
                    notificationModel!.imageUrl!.isNotEmpty)
                  ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.network(notificationModel!.imageUrl!, )),
                const SizedBox(height: 10),
                Text(
                  notificationModel!.title ?? '',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 43, 84, 1),
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  notificationModel!.message ?? '',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 43, 84, 1),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                      // Color de fondo
                      ),
                  child: SizedBox(
                    width: 400,
                    height: MediaQuery.of(context).size.width * 1,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: dataNotification.length,
                      itemBuilder: (context, index) {
                        final isFirst = index % 2 == 0;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dataNotification[index].value ?? '',
                              style: TextStyle(
                                color: isFirst
                                    ? Color.fromRGBO(1, 95, 184, 1)
                                    : null,
                                fontWeight: isFirst ? FontWeight.bold : null,
                                fontSize: 16,
                                height: isFirst ? 2.5 : 1,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ] else ...[
                const Center(
                  child: Text('Notificación no existe'),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: MyButton(),
    );
  }
}

class MyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.width * 0.12,
      child: ElevatedButton(
        onPressed: () {
          appRouter.pop();
          print('¡Haz clic en el botón!');
        },
        child: Text('Volver'),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          backgroundColor: Color.fromRGBO(19, 136, 214, 1),
        ),
      ),
    );
  }
}
