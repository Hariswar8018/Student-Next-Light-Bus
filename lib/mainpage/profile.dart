import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_next_lights_bus/main.dart';

class Pro extends StatelessWidget {
  const Pro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Column(
        children: [
          IconButton(onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
            MyHomePage(title: false,)));
          }, icon: Icon(Icons.logout))
          
        ],
      )
    );
  }
}
