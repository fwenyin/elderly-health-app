import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namer_app/l10n/app_localizations.dart';


import '../model/medication_model.dart';
import '../widget/app_bar.dart';

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
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.medicationName),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.whenToEat),
              items: [
                DropdownMenuItem(
                    child: Text(AppLocalizations.of(context)!.thrice),
                    value: "Thrice a day"),
                DropdownMenuItem(
                    child: Text(AppLocalizations.of(context)!.twice),
                    value: "Twice a day"),
                DropdownMenuItem(
                    child: Text(AppLocalizations.of(context)!.daily),
                    value: "Daily"),
                DropdownMenuItem(
                    child: Text(AppLocalizations.of(context)!.weekly),
                    value: "Weekly"),
                DropdownMenuItem(
                    child: Text(AppLocalizations.of(context)!.biweekly),
                    value: "Biweekly"),
                DropdownMenuItem(
                    child: Text(AppLocalizations.of(context)!.monthly),
                    value: "Monthly"),
                DropdownMenuItem(
                    child: Text(AppLocalizations.of(context)!.others),
                    value: "Others"),
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
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.specifyEat),
              ),
            TextFormField(
              controller: _frequencyController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.numberOfPills),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            SizedBox(height: 10.0),
            CheckboxListTile(
              title: Text(AppLocalizations.of(context)!.afterMeal),
              value: afterMeal,
              onChanged: (bool? value) {
                setState(() {
                  afterMeal = value!;
                });
              },
            ),
            SizedBox(height: 50.0),
            ElevatedButton(
              onPressed: _saveMedication,
              child: Text(AppLocalizations.of(context)!.saveChanges),
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
