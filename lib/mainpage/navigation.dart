
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_next_lights_bus/mainpage/ads.dart';
import 'package:student_next_lights_bus/mainpage/bus_details.dart';
import 'package:student_next_lights_bus/mainpage/home.dart';
import 'package:student_next_lights_bus/mainpage/map_function/display.dart';
import 'package:student_next_lights_bus/model/bus.dart';

import 'profile.dart';

class Home extends StatefulWidget {
  BusModel user;
  Home({super.key,required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Widget diu(){
    if(_currentIndex==1){
      return ViewRouteScreen(id: widget.user.id,);
    }else if(_currentIndex==2){
      return BusDetails(bus:widget.user);
    }
    return Home2(user: widget.user,);
  }
  Future<bool> _onWillPop(BuildContext context) async {
    bool exitApp = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Exit App"),
          content: Text("Are you sure you want to exit?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Stay in the app
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Exit the app
              child: Text("Exit"),
            ),
          ],
        );
      },
    ) ?? false; // If the dialog is dismissed, return false (stay in the app)
    return exitApp;
  }
  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () => _onWillPop(context),
        child: sd(false));
  }

  String df(){
    if(_currentIndex==1){
      return "Live Location";
    }else if(_currentIndex==2){
      return "Bus Profile";
    }
    return "Home";
  }


  Widget sd(bool b){
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: false,
      body: diu(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {

          _currentIndex=index;
          setState(() {

          });

        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Route",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        selectedItemColor: Colors.blueAccent, // Selected icon color
        unselectedItemColor: Colors.grey, // Unselected icon color
        backgroundColor: Colors.black, // Background color
      ),
    );
  }
  int _currentIndex = 0;
}
