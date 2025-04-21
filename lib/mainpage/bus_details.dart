import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_next_lights_bus/main.dart';
import 'package:student_next_lights_bus/mainpage/scan/students.dart';
import 'package:student_next_lights_bus/mainpage/second/edit.dart';
import 'package:student_next_lights_bus/mainpage/second/timings.dart';
import 'package:student_next_lights_bus/model/bus.dart';

class BusDetails extends StatelessWidget {
  BusModel bus;
   BusDetails({super.key,required this.bus});

  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffF6BA24),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
          }, icon: Icon(Icons.close,color: Colors.black,)),
        actions: [
          IconButton(onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                MyHomePage(title: false,)));
          }, icon: Icon(Icons.logout,color: Colors.red,)),
          SizedBox(width: 10,)
        ],
        title: Text("Bus Details",style: TextStyle(color: Colors.black),),),
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            r(bus.iseditable, "Bus Name", bus.name,context,"name"),
            r(bus.iseditable, "Bus RouteId", bus.routeId,context,"name"),
            r(false, "Bus ID", bus.uid,context,""),
            r(false, "School ID", bus.number,context,""),
            r(false, "School Name", bus.schoolname,context,""),
            r(false, "Default Session", bus.sessionid,context,""),
            r(bus.iseditable, "Bus Timings", bus.timing,context,"timing",on: true,f:true),
            InkWell(
                onTap: (){
                  print(bus.toJson());
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                      AddS(id: bus.number, buss: bus, busid: bus.id,)));
                },
                child: r(bus.couldadd, "Bus Persons", bus.people.length.toString(),context,"bus",on:true)),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left: 18.0,right: 18),
              child: Text("Description",style: TextStyle(fontWeight: FontWeight.w600),textAlign: TextAlign.left,),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0,right: 18),
              child: InkWell(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                      BusEdit(id: bus.id, docid: "timing", name: bus.name, isdesc: false, what: "Description",)));
                },
                child: Container(
                  width: w,
                  child: Text(bus.timing,textAlign: TextAlign.left),
                ),
              ),
            ),
            SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }
  int i=0;
  Widget r(bool editable,String str, String str2,BuildContext context,String strf3,{bool on=false,bool f=false}){
    i+=1;
    return on?ListTile(
      onTap: (){
        if(!editable){
          return ;
        }
        if(f){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
              Timings(bus:bus)));
        }else if(strf3=="bus"){
          print(bus.toJson());
          Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
              AddS(id: bus.number, buss: bus, busid: bus.id,)));
        }
      },
      tileColor: i%2==0?Colors.white:Colors.grey.shade100,
      leading: Icon(Icons.square_sharp),
      title: Text(str),
      trailing:editable? Icon(Icons.arrow_forward_ios_outlined,color: Colors.blueAccent,):SizedBox(),
    ):ListTile(
      onTap: (){
        if(editable){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
              BusEdit(id: bus.id, docid: strf3, name: bus.name, isdesc: false, what: str,)));
        }
      },
      tileColor: i%2==0?Colors.white:Colors.grey.shade100,
      leading: editable?Icon(Icons.edit):Icon(Icons.circle),
      title: Text(str),
      trailing: Text(str2,style: TextStyle(color: Colors.black),),
    );
  }
}
