
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_next_lights_bus/model/bus.dart';

class UserProvider extends ChangeNotifier {
  BusModel? _user;

  BusModel? get getUser => _user;

  Future<void> refreshuser() async {
    BusModel user = await GetUser();
    _user = user;
    notifyListeners();
  }

  Future<BusModel> GetUser() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('Bus')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    print(snap);
    print(BusModel.fromSnap(snap).id);
    return BusModel.fromSnap(snap);
  }
}
