import 'package:flutter/material.dart';
import 'notification_page.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   
  @override
  void initState() {
    super.initState();
    



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(38, 92, 178, 1),
        title: const Text('Flutter SNS Messaging'),
        actions: [
          IconButton(onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
            );
          }, icon: Icon(Icons.notifications_none_outlined)),
          IconButton(onPressed: ()=>{}, icon: Icon(Icons.call))
        ],
      ),
      body: const Center(
          child: Center(
            child: Text("You have been subscribed"),
          )),
    );
  }
}