import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_next_lights_bus/global/send.dart';
import 'package:student_next_lights_bus/mainpage/scan/sc.dart';
import 'package:student_next_lights_bus/mainpage/scan/students.dart';
import 'package:student_next_lights_bus/model/bus.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_background/flutter_background.dart';

class TrackBus extends StatefulWidget {
  final String id;
  final bool edit;
  BusModel bus;
  TrackBus({required this.id, required this.edit,required this.bus});

  @override
  _TrackBusState createState() => _TrackBusState();
}

class _TrackBusState extends State<TrackBus> {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Marker? _busMarker;
  Marker? _userMarker;
  BitmapDescriptor? _busIcon;
  BitmapDescriptor? _userIcon;
  StreamSubscription<Position>? _positionStream;
  late LatLng _currentLocation;
  Timer? _updateTimer;
  Position? _lastKnownPosition;
  DateTime _lastMovementTime = DateTime.now();
  Timer? _inactivityTimer;
  Timer? _noMovementTimer;

  Future<void> initializeBackgroundExecution() async {
    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "Live Bus Tracking Running",
      notificationText: "Bus location updates are active in the background",
      notificationImportance: AndroidNotificationImportance.high,
      enableWifiLock: true,
    );

    // Initialize WITH config (no need to call the empty initialize first)
    bool initialized = await FlutterBackground.initialize(androidConfig: androidConfig);
    print("FlutterBackground initialized: $initialized");

    if (initialized) {
      bool success = await FlutterBackground.enableBackgroundExecution();
      print(success
          ? "✅ Background execution enabled"
          : "❌ Failed to enable background execution");
    } else {
      print("❌ FlutterBackground initialization failed.");
    }
  }


  void _startNoMovementCheck() {
    _noMovementTimer?.cancel();
    _noMovementTimer = Timer.periodic(Duration(seconds: 90), (timer) {
      if (_lastKnownPosition != null) {
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((pos) {
          double distance = Geolocator.distanceBetween(
            _lastKnownPosition!.latitude,
            _lastKnownPosition!.longitude,
            pos.latitude,
            pos.longitude,
          );
          if (distance < 4) {
            Send.message(context, "Bus location hasn't changed for 1 minute......Thus Deleted", false);
            Timer(Duration(seconds: 5), () {
              _cleanupTimers();
              Navigator.pop(context, true);
            });
          } else {
            _lastKnownPosition = pos;
          }
        }).catchError((e) {
          print("Error in no-movement check: $e");
        });
      }
    });
  }

  Future<void> _createOrUpdateBusLocation(String docId) async {
    _updateTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      print(_isDisposed);
      if (_isDisposed) return;
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        if (_lastKnownPosition == null) {
          _lastKnownPosition = position;
          _startNoMovementCheck(); //
        }
        DocumentReference busDoc = FirebaseFirestore.instance.collection("Bus").doc(docId);
        await busDoc.update({
          "liveLocation": {
            "lat": position.latitude,
            "lng": position.longitude,
          },
          "createdAt": Timestamp.now(),
        });
        print("Document created or updated with liveLocation.");
      } catch (e) {
        print("Error creating or updating document: $e");
      }
    });
  }
  bool _isDisposed = false;


  void _cleanupTimers() {
    _isDisposed = true;
    _updateTimer?.cancel();
    _inactivityTimer?.cancel();
    _noMovementTimer?.cancel();
    _positionStream?.cancel();
    FlutterBackground.disableBackgroundExecution(); // Optionally disable background execution
  }

  @override
  void dispose() {
    _cleanupTimers();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    initializeBackgroundExecution();
    sendtokens();
    _createOrUpdateBusLocation(widget.id);
    _fetchInitialLocation();
    _setCustomMarkers();
    _loadRouteFromFirestore();
    _startBusLocationUpdates();
  }


  Future<BitmapDescriptor> getResizedMarker(String assetPath, int width) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    final codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
    final frame = await codec.getNextFrame();
    final ByteData? resized = await frame.image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(resized!.buffer.asUint8List());
  }



  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        persistentFooterButtons: [
          InkWell(
              onTap: (){
               showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Students Doing What?"),
                    content: Text("Please Select are Students going IN or Out"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                              QRViewExample(str: widget.bus.schoolname, id: widget.bus.number, status: "In", sms: false,)));

                        }, // Stay in the app
                        child: Text("In"),
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                              QRViewExample(str: widget.bus.schoolname, id: widget.bus.number, status: "Out", sms: false,)));

                        },
                        child: Text("Out"),
                      ),
                    ],
                  );
                },
                );
                  },
              child: Center(child: Send.see(w, "Scan ID Card", Icon(Icons.qr_code)))),
        ],
        appBar: AppBar(
            backgroundColor: Send.color,
            title: Text("Live Bus Tracking"),
          actions: [
            IconButton(onPressed:(){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  AddS(id: widget.bus.number, buss: widget.bus, busid: widget.bus.id,)));
            }, icon: Icon(Icons.supervised_user_circle))
          ],
        ),
        body:_initialLocation == null
            ? Center(child: CircularProgressIndicator())
            :  GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialLocation!,
            zoom: 15,
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          markers: {
            if (_busMarker != null) _busMarker!,
            if (_userMarker != null) _userMarker!,
          },
          polylines: _polylines,
        ),
      ),
    );
  }



  // Set custom markers for Bus and User
  Future<void> _setCustomMarkers() async {
    _busIcon = await getResizedMarker("assets/bus.png", 250); // Try 80 for small size
    _userIcon = await getResizedMarker("assets/user.png", 250);
  }

  void _startBusLocationUpdates() {
    try {
      _updateTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
        DocumentSnapshot busSnapshot = await FirebaseFirestore.instance.collection("Bus").doc(widget.id).get();
        print("xxxxxxxxx");
        if (busSnapshot.exists && busSnapshot["liveLocation"] != null) {
          LatLng busLatLng = LatLng(
            busSnapshot["liveLocation"]["lat"],
            busSnapshot["liveLocation"]["lng"],
          );
          print("on");
          setState(() {
            _busMarker = Marker(
              markerId: MarkerId("bus"),
              position: busLatLng,
              icon: _busIcon ?? BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(title: "Bus Location"),
            );
          });
          _mapController?.animateCamera(CameraUpdate.newLatLng(busLatLng));
        }
      });
    }catch(e){
      Send.message(context, "$e", false);
    }
  }

  void sendtokens(){
    try{
      Send.sendNotification("Bus Started !", "Our School Bus Started from Destination", widget.bus.tokens);
    }catch(e){

    }
  }



  LatLng? _initialLocation;
  Future<void> _fetchInitialLocation() async {
    try {
      LatLng currentLocation = await _getCurrentLocation();
      setState(() {
        _initialLocation = currentLocation;
      });
    } catch (e) {
      print("Error fetching location: $e");
      // Fallback to a default location if location is not available
      setState(() {
        _initialLocation = LatLng(28.7041, 77.1025); // Default to Delhi
      });
    }
  }
  Future<bool> _onWillPop(BuildContext context) async {
    bool exitApp = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Exit Live Location"),
          content: Text("Are you sure you want to exit? Bus will marked as Stop"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Stay in the app
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: (){
                _cleanupTimers();
                Navigator.pop(context, true);
              } ,// Exit the app
              child: Text("Exit"),
            ),
          ],
        );
      },
    ) ?? false; // If the dialog is dismissed, return false (stay in the app)
    return exitApp;
  }

  Future<LatLng> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied.");
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LatLng(position.latitude, position.longitude);
  }
  Future<void> _loadRouteFromFirestore() async {
    DocumentSnapshot routeSnapshot = await FirebaseFirestore.instance
        .collection("Bus")
        .doc(widget.id)
        .collection("Route")
        .doc(widget.id)
        .get();

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
}
