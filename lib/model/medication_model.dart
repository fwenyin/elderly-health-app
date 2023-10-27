import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final bool afterMeal;

  Medication(
      {required this.id,
      required this.name,
      required this.dosage,
      required this.frequency,
      required this.afterMeal});

  factory Medication.fromDocument(DocumentSnapshot doc) {
    return Medication(
        id: doc.id,
        name: doc['name'],
        dosage: doc['dosage'],
        frequency: doc['frequency'],
        afterMeal: doc['afterMeal']);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'afterMeal': afterMeal,
      };
}
