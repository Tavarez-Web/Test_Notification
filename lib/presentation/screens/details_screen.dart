import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_notification/config/router/app_router.dart';

import '../../db.helper.dart';
import '../../notification_model.dart';

class DetailScreen extends StatefulWidget {
  final String pushMessaheId;

  const DetailScreen({super.key, required this.pushMessaheId});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  NotificationModel? notificationModel = NotificationModel();
  List<TypeNotification> dataNotification = List.empty();
  String data = "";
  @override
  void initState() {
    super.initState();
   
    Future.delayed(Duration.zero, () async {
      var notification = await DatabaseHelper.instance
          .getNotificationById(int.parse(widget.pushMessaheId));

      setState(() {
        notificationModel = notification;
        data = notificationModel!.data!;
      });

      String arrayString = jsonEncode(data);
      List<String> arrayItems = arrayString.split(', ');
      var myObjects = arrayItems.map((item) {
        List<String> keyValue = item.split(': ');
        String name = keyValue[0].trim().replaceAll('{', '');
        String value = keyValue[1].trim().replaceAll('}', '');

        print(name);
        print(value);

        return TypeNotification(name: name, value: value);
      }).toList();
   
    dataNotification = myObjects;
    
    });
  }

  @override
  Widget build(BuildContext context) {
    // final PushMessage? message = context.watch<NotificationsBloc>()
    // .getMessageById( pushMessaheId );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            appRouter.pop(context);
          },
        ),
        title: const Text('Detalles Push'),
      ),
      body: (notificationModel != null)
          ? DetailsView(message: notificationModel!, dataNotification: dataNotification)
          : const Center(
              child: Text('Notificacion no existe'),
            ),
    );
  }
}

class DetailsView extends StatefulWidget {
  final NotificationModel message;
  //  final TypeNotification dataNotification;
   final List<TypeNotification> dataNotification;
   const DetailsView({required this.message,required this.dataNotification});

  @override
  _DetailsView createState() => _DetailsView();
}

class _DetailsView extends State<DetailsView> {
  List<TypeNotification> dataNotification = List.empty();

  bool firstTime = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var listAmount = widget.message.data;
      print("montos ${listAmount}");
      print("montos ${listAmount}");
    
    });

  
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    // print(message.id);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(children: [
        if (widget.message.imageUrl != null &&
            widget.message.imageUrl!.isNotEmpty)
          Image.network(widget.message.imageUrl!),
        const SizedBox(height: 10),
        Text(widget.message.title ?? '', style: textStyles.titleLarge),
        const SizedBox(height: 30),
        Text(widget.message.message ?? ''),
        Text(widget.message.data ?? ''),

        const SizedBox(height: 30),
        const SizedBox(height: 30),
        Text(widget.message.id.toString()),

        // const Divider(),
        // Text(dataNotification[1].name ?? ''),
        Container(
          decoration: BoxDecoration(
              // Color de fondo
              ),
          child: SizedBox(
            width: 400,
            height: 400,
            child: Align(
              alignment: Alignment.centerLeft, // Alineación a la izquierda
              child: ListView.builder(
                itemCount: widget.dataNotification.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.dataNotification[index].name ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(widget.dataNotification[index].value ?? ''),
                      const Divider()
                    ],
                  );
                },
              ),
            ),
          ),
        )
      ]),
    );
  }
}
