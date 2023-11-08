import 'package:cloud_firestore/cloud_firestore.dart';

class Food {
  final String name;
  final String mealType;
  final DateTime timestamp;
  final double kcal;
  final double carbs;

  Food({
    required this.name,
    required this.mealType,
    required this.timestamp,
    required this.kcal,
    required this.carbs,
  });

  factory Food.fromDocument(DocumentSnapshot doc) {
    return Food(
      name: doc['name'],
      mealType: doc['mealType'],
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
      kcal: doc['kcal'],
      carbs: doc['carbs'],
    );
  }
}
