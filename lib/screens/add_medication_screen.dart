import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/medication_model.dart';

class MedicationScreen extends StatefulWidget {
  final Medication? medication;

  MedicationScreen({this.medication});

  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _frequencyController;
  bool _isOthersSelected = false;
  bool afterMeal = false;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.medication?.name ?? "");
    _dosageController =
        TextEditingController(text: widget.medication?.dosage ?? "");
    _frequencyController =
        TextEditingController(text: widget.medication?.frequency ?? "");

    if (widget.medication != null) {
      afterMeal = widget.medication!.afterMeal;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('My Medications')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Medication Name'),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'When to eat?'),
              items: [
                DropdownMenuItem(
                    child: Text("Thrice a day"), value: "Thrice a day"),
                DropdownMenuItem(
                    child: Text("Twice a day"), value: "Twice a day"),
                DropdownMenuItem(child: Text("Daily"), value: "Daily"),
                DropdownMenuItem(child: Text("Weekly"), value: "Weekly"),
                DropdownMenuItem(child: Text("Biweekly"), value: "Biweekly"),
                DropdownMenuItem(child: Text("Monthly"), value: "Monthly"),
                DropdownMenuItem(child: Text("Others"), value: "Others"),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  _dosageController.text = value;
                  if (value == "Others") {
                    setState(() {
                      _isOthersSelected = true;
                    });
                  } else {
                    _dosageController.text = value;
                    setState(() {
                      _isOthersSelected = false;
                    });
                  }
                }
              },
              value: _dosageController.text.isEmpty
                  ? null
                  : _dosageController.text,
            ),
            if (_isOthersSelected)
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(labelText: 'Specify when to eat (eg. 3 times a week)'),
              ),
            TextFormField(
              controller: _frequencyController,
              decoration: InputDecoration(labelText: 'Number of pills'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            CheckboxListTile(
              title: Text('After Meal'),
              value: afterMeal,
              onChanged: (bool? value) {
                setState(() {
                  afterMeal = value!;
                });
              },
            ),
            ElevatedButton(
              onPressed: _saveMedication,
              child: Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }

  void _saveMedication() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    if (widget.medication != null) {
      // Update existing medication
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('medications')
          .doc(widget.medication!.id)
          .update({
        'name': _nameController.text,
        'dosage': _dosageController.text,
        'frequency': _frequencyController.text,
        'afterMeal': afterMeal,
      });
    } else {
      // Add new medication
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('medications')
          .add({
        'name': _nameController.text,
        'dosage': _dosageController.text,
        'frequency': _frequencyController.text,
        'afterMeal': afterMeal,
      });
    }

    Navigator.of(context).pop();
  }
}
