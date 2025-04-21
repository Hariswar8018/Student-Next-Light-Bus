import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:student_next_lights_bus/global/send.dart';

class BusRouteScreen extends StatefulWidget {
  String routeid, id;
  bool neww;
  BusRouteScreen({required this.id,required this.routeid,required this.neww});
  @override
  _BusRouteScreenState createState() => _BusRouteScreenState();
}

class _BusRouteScreenState extends State<BusRouteScreen> {
  GoogleMapController? _mapController;
  List<LatLng> _routePoints = [];
  Set<Polyline> _polylines = {};

  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xffF6BA24),
          title: Text("Create Bus Route",style: TextStyle(color: Colors.black),),),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(28.7041, 77.1025),
          zoom: 12,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        onTap: _addPointToRoute, // Add points on tap
        polylines: _polylines,
      ),
      persistentFooterButtons: [
        InkWell(
            onTap: _saveRouteToFirestore,
            child: Center(child: Send.se(w, "Save this Route"))),
      ],
    );
  }

  // Add tapped points to route
  void _addPointToRoute(LatLng point) {
    setState(() {
      _routePoints.add(point);
      _polylines.clear();
      _polylines.add(Polyline(
        polylineId: PolylineId("busRoute"),
        points: _routePoints,
        color: Colors.blue,
        width: 5,
      ));
    });
  }

  // Save route to Firestore
  Future<void> _saveRouteToFirestore() async {
    if (_routePoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No route points to save"))
      );
      return;
    }

    List<Map<String, double>> routeData = _routePoints.map((point) => {
      "lat": point.latitude,
      "lng": point.longitude,
    }).toList();

    if(widget.neww){
      try {
        await FirebaseFirestore.instance
            .collection("Bus")
            .doc(widget.id)
            .collection("Route")
            .doc(widget.id)
            .set({
          "routeId": widget.id,
          "points": routeData,
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Route saved successfully!"))
        );
        Navigator.pop(context);
      } catch (e) {
        print("Error saving route: $e");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to save route: $e"))
        );
      }
    }
    try {
      await FirebaseFirestore.instance
          .collection("Bus")
          .doc(widget.id)
          .collection("Route")
          .doc(widget.id)
          .update({
        "routeId": widget.id,
        "points": routeData,
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Route saved successfully!"))
      );
    } catch (e) {
      print("Error saving route: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save route: $e"))
      );
    }
  }
}
