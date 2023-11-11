import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/medication_model.dart';
import '../screens/add_medication_screen.dart';

class MedicationOverview extends StatefulWidget {
  @override
  _MedicationOverviewState createState() => _MedicationOverviewState();
}

class _MedicationOverviewState extends State<MedicationOverview> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String todayDate = DateTime.now().toIso8601String().split('T')[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Medications Overview",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _getCurrentCheckboxState(),
              builder: (context, snapshot) {
                Map<String, dynamic>? dailyCheckboxState =
                    snapshot.data?.data() as Map<String, dynamic>?;

                return StreamBuilder<List<Medication>>(
                  stream: _getMedications(),
                  builder: (context, medicationSnapshot) {
                    if (medicationSnapshot.hasData) {
                      List<Medication> medications = medicationSnapshot.data!;

                      if (medications.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('You have no medications added.'),
                              /*
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          MedicationScreen()));
                                },
                                child: Text('Add Medication'),
                              )
                              */
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: medications.length,
                        itemBuilder: (context, index) {
                          final medication = medications[index];
                          bool isChecked =
                              dailyCheckboxState?[medication.id] ?? false;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 2),
                            child: Card(
                              elevation: 5.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child:
                                  _buildMedicationItem(medication, isChecked),
                            ),
                          );
                        },
                      );
                    } else if (medicationSnapshot.hasError) {
                      return Center(child: Text("Error fetching medications"));
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => MedicationScreen()),
          );
        },
      ),
    );
  }

  Widget _buildMedicationItem(Medication medication, bool isChecked) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.5),
      leading: Checkbox(
        value: isChecked,
        onChanged: (bool? value) {
          if (value != null) {
            _updateCheckboxState(medication.id, value);
          }
        },
      ),
      title: Text('${medication.name}', style: TextStyle(fontSize: 14,
          fontWeight: FontWeight.bold
        ),
      ),
      subtitle: Text(
          'Dosage: ${medication.frequency} \n${medication.afterMeal ? "After meal" : "Before meal"}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to another screen to edit the medication
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) =>
                        MedicationScreen(medication: medication)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteMedication(medication.id);
            },
          ),
        ],
      ),
    );
  }

  Stream<List<Medication>> _getMedications() {
    String userId = _auth.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('medications')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Medication.fromDocument(doc)).toList());
  }

  Future<void> _deleteMedication(String medicationId) async {
    String userId = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('medications')
        .doc(medicationId)
        .delete();

    // You might also want to remove any references to the medication from 'dailyCheckboxStates'
    // For this example, I'm leaving it as is.
  }

  Future<void> _updateCheckboxState(String medicationId, bool isChecked) async {
    String userId = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('dailyCheckboxStates')
        .doc(todayDate)
        .set({medicationId: isChecked}, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> _getCurrentCheckboxState() {
    String userId = _auth.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('dailyCheckboxStates')
        .doc(todayDate)
        .snapshots();
  }
}
