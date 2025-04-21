import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:student_next_lights_bus/global/send.dart';

class LocationPicker extends StatefulWidget {
  final Function(LatLng) onLocationPicked;
  double lat, long;
  LocationPicker({required this.onLocationPicked, Key? key,required this.lat,required this.long}) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student Location")),
      body:  GoogleMap(
        initialCameraPosition: CameraPosition(target: LatLng(widget.lat, widget.long), zoom: 15),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: _selectedLocation != null
            ? {
          Marker(
            markerId: MarkerId("selected_location"),
            position: _selectedLocation!,
            infoWindow: InfoWindow(title: "Selected Location"),
          ),
        }
            : {},
      ),
    );
  }

  late GoogleMapController _mapController;

  late LatLng _selectedLocation ;

  void initState(){
    _selectedLocation = LatLng(widget.lat, widget.long);
  }
}
