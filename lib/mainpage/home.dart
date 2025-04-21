import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:student_next_lights_bus/global/send.dart';
import 'package:student_next_lights_bus/mainpage/bus_details.dart';
import 'package:student_next_lights_bus/mainpage/map_function/create.dart';
import 'package:student_next_lights_bus/mainpage/map_function/display.dart';
import 'package:student_next_lights_bus/mainpage/map_function/track.dart';
import 'package:student_next_lights_bus/mainpage/scan/students.dart';
import 'package:student_next_lights_bus/mainpage/second/timings.dart';
import 'package:student_next_lights_bus/model/bus.dart';
import 'package:student_next_lights_bus/model/route.dart';

class Home2 extends StatelessWidget {
  BusModel user;
  Home2({super.key,required this.user});

  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffF6BA24),
          title: Text("Home",style: TextStyle(color: Colors.black),),),
      backgroundColor: Colors.white,
      body:FutureBuilder<RouteModel?>(
        future: getUserByUid(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            return Start(snapshot.data!,w,h,context,user);
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network("https://media.istockphoto.com/id/1299133253/photo/concept-school-bus-route-on-the-map.jpg?s=612x612&w=0&k=20&c=y3fq5VeIMT8SuY1QHwQ5dvKzLSia2cO27ScwCN29A14="),
                Center(child: Text("No Bus Route found out",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w800),)),
                Center(child: Padding(
                  padding: const EdgeInsets.only(left: 18.0,right: 18),
                  child: Text(textAlign: TextAlign.center,"You need to create one ! To use this Dashboard",style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500),),
                )),
                SizedBox(height: 10,),
                Center(
                  child: InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => BusRouteScreen(id: user.id, routeid: user.id, neww: true,)));
                    },
                    child:fetching?CircularProgressIndicator(
                      backgroundColor: Color(0xff009788),
                    ): Container(
                      width: w-60,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Color(0xff009788),
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Center(child: Text("Create Now",style: TextStyle(color: Colors.white,fontSize: 18),)),
                    ),
                  ),
                )
              ],
            );
          }
        },
      )
    );
  }
  Widget Start(RouteModel user,double w,double h,BuildContext context, BusModel bus){
    return Container(
      width: w,height: h,
      child: Column(
        children: [
          Container(
            width: w,height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/busgif.gif"))
            ),
          ),
          SizedBox(height: 20,),
          Container(
            width: w-30,
            height: 45,
            decoration: BoxDecoration(
              color: Send.color,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(child: Text("Bus Name : ${bus.name}",style: TextStyle(fontWeight: FontWeight.w700),),),
          ),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                        ViewRouteScreen(id: user.routeId)));
                  },
                  child: Send.see(w/2+10, "Check Route",Icon(Icons.location_on,))),
              InkWell(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                        Timings(bus:bus)));
                  },
                  child: Send.see(w/2+10, "Timing",Icon(Icons.alarm,))),
            ],
          ), SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                        BusDetails(bus:bus)));
                  },
                  child: Send.see(w/2+10, "Bus Info",Icon(Icons.info,))),
              InkWell(
                  onTap: (){
                    print(bus.toJson());
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                    AddS(id: bus.number, buss: bus, busid: bus.id,)));
                  },
                  child: Send.see(w/2+10, "Students",Icon(Icons.supervised_user_circle,))),
            ],
          ),
          SizedBox(height: 20,),
          InkWell(
            onTap: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Start Bus? "),
                    content: Text("You are not allowed to do any Action while Bus start ! Background Location Permission needed"),
                    actions: [
                      TextButton(
                        onPressed: () async{
                          Navigator.pop(context);
                          var locationPermission = await Permission.locationWhenInUse.status;
                          if (locationPermission.isGranted) {
                            Send.message(context, "Foreground location permission is Accepted", true);
                            print("Foreground location permission is granted.");
                          } else if (locationPermission.isDenied) {
                            print("Foreground location permission is denied.");
                            Send.message(context, "Foreground location permission is denied", false);
                            await Permission.locationWhenInUse.request();
                          } else if (locationPermission.isPermanentlyDenied) {
                            Send.message(context, "Foreground location permission is permanently denied", false);
                            print("Foreground location permission is permanently denied.");
                            await openAppSettings();
                          }
                          var backgroundPermission = await Permission.locationAlways.status;
                          if (backgroundPermission.isGranted) {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => TrackBus(id: user.routeId, edit: true, bus: bus,)));
                            print("Background location permission is granted.");
                          } else if (backgroundPermission.isDenied) {
                            Send.message(context, "Background location permission is denied", false);
                            print("Background location permission is denied.");
                            // Request the permission
                            await Permission.locationAlways.request();
                          } else if (backgroundPermission.isPermanentlyDenied) {
                            Send.message(context, "Background location permission is permanently denied", false);
                            print("Background location permission is permanently denied.");
                            // Open app settings to manually enable
                            await openAppSettings();
                          }
                        }, // Stay in the app
                        child: Text("Ok"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Exit the app
                        child: Text("Exit"),
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              width: w-30,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade300,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Send.color,
                  width: 2
                )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bus_alert_rounded,),SizedBox(width: 15,),
                  Text("Start Bus",style: TextStyle(fontWeight: FontWeight.w800,fontSize: 19),),SizedBox(width: 15,),
                  Icon(Icons.bus_alert_rounded,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  bool fetching=false,yes=false;
  Future<RouteModel?> getUserByUid() async {
    try {
      CollectionReference usersCollection = FirebaseFirestore.instance.collection("Bus").doc(user.id).collection("Route");
      QuerySnapshot querySnapshot = await usersCollection.where('routeId', isEqualTo: user.id).get();
      if (querySnapshot.docs.isNotEmpty) {
        RouteModel user = RouteModel.fromSnap(querySnapshot.docs.first);
        print(user);
        return user;
      } else {
        print("sgrfhgkjkhj");
        return null;
      }
    } catch (e) {
      print("Error fetching user by uid: $e");
      return null;
    }
  }
}
