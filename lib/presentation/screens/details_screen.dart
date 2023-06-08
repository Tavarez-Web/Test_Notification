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

  @override
  void initState() {
    super.initState();
    // context.read<NotificationsBloc>().getMessages();

    // postFramewidget
    Future.delayed(Duration.zero, () async {
      var notification = await DatabaseHelper.instance
          .getNotificationById(int.parse(widget.pushMessaheId));

      setState(() {
        notificationModel = notification;
      });
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
      ?DetailsView(message: notificationModel!)
      : const Center( child: Text('Notificacion no existe'),),
    );
  }
}


class DetailsView extends StatefulWidget{

   final NotificationModel message;
  //  final TypeNotification dataNotification;
   const DetailsView({required this.message});
   
    @override
  _DetailsView createState() => _DetailsView();
}
  class _DetailsView extends State <DetailsView> {
  List<TypeNotification>dataNotification = List.empty();

@override
  void initState() {
    super.initState();
    // context.read<NotificationsBloc>().getMessages();

    // postFramewidget
    Future.delayed(Duration.zero, () async {
      var notification = await DatabaseHelper.instance
          .getDataNotificationById(widget.message.id ?? 0);
          print(notification);
      setState(() {
        dataNotification = notification;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    // print(message.id);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(children: [
        if (widget.message.imageUrl.isNotEmpty) Image.network(widget.message.imageUrl!),
        const SizedBox(height: 10),
        Text(widget.message.title ?? '', style: textStyles.titleLarge),
        const SizedBox(height: 30),
        Text(widget.message.message ?? ''),
        
        const SizedBox( height: 30),
        //  const SizedBox(height: 30),
        // Text(widget.message.message ?? ''),
        
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
        itemCount: dataNotification.length,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dataNotification[index].name ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(dataNotification[index].value ?? ''),
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
