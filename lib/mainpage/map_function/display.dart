import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_next_lights_bus/global/send.dart';

class ViewRouteScreen extends StatefulWidget {
  String id;
  ViewRouteScreen({required this.id});
  @override
  _ViewRouteScreenState createState() => _ViewRouteScreenState();
}

class _ViewRouteScreenState extends State<ViewRouteScreen> {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadRouteFromFirestore();
    _getCurrentLocation();
  }

  Future<LatLng> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    // If permission is granted
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return LatLng(position.latitude, position.longitude);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Send.color,
          title: Text("View Bus Route")),
      body: FutureBuilder<LatLng>(
          future: _getCurrentLocation(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            LatLng initialPosition = snapshot.data!;
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialPosition,
                zoom: 12,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              polylines: _polylines,
            );
          }
      ),
    );
  }

  Future<void> _loadRouteFromFirestore() async {
    DocumentSnapshot routeSnapshot = await FirebaseFirestore.instance.collection("Bus").doc(widget.id).collection("Route").doc(widget.id).get();

    if (routeSnapshot.exists) {
      List<dynamic> pointsData = routeSnapshot["points"];
      List<LatLng> routePoints = pointsData.map((point) => LatLng(point["lat"], point["lng"])).toList();

      setState(() {
        _polylines.add(Polyline(
          polylineId: PolylineId(widget.id),
          points: routePoints,
          color: Colors.blue,
          width: 5,
        ));
      });
    }
  }


  String routeId = "bus_route_123";
  Marker? _busMarker;
  BitmapDescriptor? _busIcon;
  StreamSubscription<Position>? _positionStream;
  late LatLng _currentLocation;

  Future<void> _setCustomMarker() async {
    _busIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      "assets/bus.png", // Add a custom bus icon in assets
    );
  }

  // Start tracking user's live location
  void _startTracking() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
      ),
    ).listen((Position position) {
      _currentLocation = LatLng(position.latitude, position.longitude);

      // Update Firestore with current location
      FirebaseFirestore.instance.collection("Bus").doc(widget.id).update({
        "liveLocation": {
          "lat": position.latitude,
          "lng": position.longitude,
        }
      });

      setState(() {
        _busMarker = Marker(
          markerId: MarkerId("bus"),
          position: _currentLocation,
          icon: _busIcon ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: "Bus Location"),
        );
      });

      // Move camera to new position
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentLocation),
      );
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}
