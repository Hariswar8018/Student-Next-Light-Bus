import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:student_next_lights_bus/firebase_options.dart';
import 'package:student_next_lights_bus/login/login.dart';
import 'package:student_next_lights_bus/login/onboarding.dart';
import 'package:student_next_lights_bus/mainpage/navigation.dart';
import 'package:student_next_lights_bus/model/bus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: false,),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({super.key, required this.title});
  final bool title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void initState(){
    Timer(Duration(seconds: 3), () async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print("Exists");
        print(user.uid);
        setState(() {
          b=true;
        });
      } else {
        print("Going...................90");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>ProfileM(str: "Bus")));
      }
    });
  }
  Future<BusModel?> getUserByUid(String uid) async {
    try {
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('Bus');
      QuerySnapshot querySnapshot = await usersCollection.where('uid', isEqualTo: uid).get();

      if (querySnapshot.docs.isNotEmpty) {
        BusModel user = BusModel.fromSnap(querySnapshot.docs.first);
        return user;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user by uid: $e");
      return null;
    }
  }
  Widget f(String uid){
    return FutureBuilder<BusModel?>(
      future: getUserByUid(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          return Home(user:snapshot.data!);
        } else {
          return Center(child: InkWell(
              onTap: () async {

              },
              child: Text("User not found")));
        }
      },
    );
  }
bool b=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: b?f(FirebaseAuth.instance.currentUser!.uid):Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Image(
            image: AssetImage('assets/logo.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
