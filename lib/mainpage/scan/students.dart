import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:student_next_lights_bus/global/send.dart';
import 'package:student_next_lights_bus/mainpage/scan/showlocation.dart';
import 'package:student_next_lights_bus/model/bus.dart';
import 'package:student_next_lights_bus/model/student_model.dart';

class AddS extends StatelessWidget {
  String id;String busid;BusModel buss;
  AddS({super.key,required this.id,required this.busid,required this.buss});
  List<StudentModel> list = [];
  late Map<String, dynamic> userMap;
  TextEditingController ud = TextEditingController();
  TextEditingController _controller=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Bus Students"),
      ),
      body:_controller.text.isEmpty?StreamBuilder(
        stream: FirebaseFirestore.instance.collection('School')
            .doc(id)
            .collection('Students').where("busid",isEqualTo: busid)
            .snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data?.docs;
              list =
                  data?.map((e) => StudentModel.fromJson(e.data())).toList() ??
                      [];
              return ListView.builder(
                  itemCount: list.length,
                  padding: EdgeInsets.only(top: 10),
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChatUser(
                      user: list[index],
                      id : id,busid: busid,
                      buss: buss,
                    );
                  });
          }
        },
      ):StreamBuilder(
        stream: FirebaseFirestore.instance.collection('School')
            .doc(id)
            .collection('Students').where("Name",isGreaterThanOrEqualTo: _controller.text)
            .snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data?.docs;
              list =
                  data?.map((e) => StudentModel.fromJson(e.data())).toList() ??
                      [];
              return ListView.builder(
                  itemCount: list.length,
                  padding: EdgeInsets.only(top: 10),
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChatUser(
                      user: list[index],
                      id : id,busid:busid,buss: buss,
                    );
                  });
          }
        },
      ),
    );
  }
}


class ChatUser extends StatefulWidget {
  StudentModel user; String id ;
  BusModel buss;
  String busid;
  ChatUser({
    super.key,
    required this.user, required this.id,required this.busid,required this.buss,
  });

  @override
  State<ChatUser> createState() => _ChatUserState();
}

class _ChatUserState extends State<ChatUser> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context) =>LocationPicker(onLocationPicked: (LatLng ) {  }, lat: widget.user.latitude, long: widget.user.longitude,)));
      },
      leading: CircleAvatar(
        backgroundImage: NetworkImage(widget.user.pic),
      ),
      trailing:widget.user.bus? CircleAvatar(
        backgroundColor: Colors.blue,
        child: Center(
          child: Icon(Icons.bus_alert_rounded,color: widget.user.busid==widget.busid?Colors.white:Colors.red),
        ),
      ):SizedBox(),
      title: Text(widget.user.Name, style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Future<void> as(double lat,double lon)async{
    try {
      await FirebaseFirestore.instance.collection("School").doc(widget.id).collection("Students").doc(widget.user.Registration_number).update({
        "busid":widget.buss.id,
        "bus":true,
        "busout":true,
        "busin":widget.buss.id,
        "latitude":lat,
        "longitude":lon,
      });
      await FirebaseFirestore.instance.collection("Bus").doc(widget.busid).update({
        "people":FieldValue.arrayUnion([widget.user.Registration_number]),
        "tokens":FieldValue.arrayUnion([widget.user.token]),
      });
      Navigator.pop(context);
      Send.message(context, "$lat $lon", true);
      print(lon);
    }catch(e){
      Send.message(context, "$e", true);
    }
  }

  Future<void> ass()async{
    try {
      await FirebaseFirestore.instance.collection("School").doc(widget.id).collection("Students").doc(widget.user.Registration_number).update({
        "busid":"",
        "bus":false,
        "busout":false,
        "busin":"",
      });
      await FirebaseFirestore.instance.collection("Bus").doc(widget.busid).update({
        "people":FieldValue.arrayRemove([widget.user.Registration_number]),
        "tokens":FieldValue.arrayRemove([widget.user.token]),
      });
      Send.message(context, "Removed", true);
    }catch(e){
      Send.message(context, "$e", true);
    }
  }
}