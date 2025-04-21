import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteModel {
  late final String routeId;
  late final String name;
  late final List<Map<String, double>> waypoints; // Updated to List<Map<String, double>>

  RouteModel({
    required this.routeId,
    required this.name,
    required this.waypoints,
  });

  // Convert Firestore Document to RouteModel
  RouteModel.fromJson(Map<String, dynamic> json) {
    routeId = json['routeId'] ?? '';
    name = json['name'] ?? '';
    waypoints = (json['points'] as List)
        .map((point) => {
      "lat": (point['lat'] as num).toDouble(),
      "lng": (point['lng'] as num).toDouble(),
    })
        .toList();
  }

  // Convert RouteModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'name': name,
      'points': waypoints, // Directly storing as List<Map<String, double>>
    };
  }

  static RouteModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return RouteModel.fromJson(snapshot);
  }
}
