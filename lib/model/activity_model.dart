import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String name;
  final int duration;
  final Timestamp timestamp;

  Activity(
      {required this.name, required this.duration, required this.timestamp});

  factory Activity.fromDocument(QueryDocumentSnapshot doc) {
    return Activity(
      name: doc['name'],
      duration: doc['duration'],
      timestamp: doc['timestamp'],
    );
  }
}
