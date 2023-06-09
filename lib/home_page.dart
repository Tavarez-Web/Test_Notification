import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'notification_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool subscribed = true;
  String? token;

  @override
  void initState() {
    super.initState();
    getToken();
  }

  Future<void> getToken() async {
    token = await FirebaseMessaging.instance.getToken();
    print("tokenen main = $token");
  }

  void postRequest(bool hasNotification) async {
    if (token == null) {
      print('Token not available');
      return;
    }

    Dio dio = Dio();
    dio.options.headers['x-api-key'] = 'eEVJ2u4s63zmn5T5KEBwaIj1Kp8fEJbaYwH7RIJd';
    Map<String, dynamic> requestBody = {
      "codCanal": "AppMovil",
      "codUsuario": "00201532999",
      "token": token,
      "hasNotification": hasNotification
    };

    try {
      Response response = await dio.post('https://8lxsb2wl7g.execute-api.us-east-1.amazonaws.com/DEV/siembra/digital/comun/sns-topic/suscribirDesuscribir', data: requestBody);
      print('Código de estado: ${response.statusCode}');
      print('Respuesta: ${response.data}');
    } catch (error) {
      print('Error en la solicitud: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(38, 92, 178, 1),
        title: const Text('Flutter SNS Messaging'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
            icon: Icon(Icons.notifications_none_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.call),
          ),
        ],
      ),
      body: Center(
        child: SwitchExample(
          subscribed: subscribed,
          onValueChanged: (value) {
            setState(() {
              subscribed = value;
              print(value);
              postRequest(subscribed);
            });
          },
        ),
      ),
    );
  }
}

class SwitchExample extends StatelessWidget {
  final bool subscribed;
  final ValueChanged<bool> onValueChanged;

  const SwitchExample({Key? key, required this.subscribed, required this.onValueChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: subscribed,
      activeColor: Colors.blue,
      onChanged: onValueChanged,
    );
  }
}
