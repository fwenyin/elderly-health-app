import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String location;
  final String department;
  final DateTime datetime;

  Appointment({
    required this.id,
    required this.location,
    required this.department,
    required this.datetime,
  });

  factory Appointment.fromDocument(DocumentSnapshot doc) {
    return Appointment(
      id: doc.id,
      location: doc['location'],
      department: doc['department'],
      datetime: (doc['datetime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'location': location,
        'department': department,
        'datetime': datetime,
      };
}
