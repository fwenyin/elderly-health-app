import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namer_app/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<void> sendFCMNotification(String title, String body) async {
    const String fcmUrl =
        'https://fcm.googleapis.com/v1/projects/elderly-health-app/messages:send';
    const String fcmToken =
        'ya29.c.c0AY_VpZi8XR6Qqy6aeW7yMq3szZwFXpiGYHDvqAxML7Q3GFCz84KcV4ozhBLaOnEFZMyQds32RqrmegY7vAlQwZiAnQi6HI6bTXTBKal5BXGkVRZsXtGT-bnBargajxyoNFGpP-tTiAgWfuS0XbCe9eeJL7Ed9cy_CfxBQqyrR0omkKZD0Q3z6DQhMhscapfosSLagQ1jG4kJ-ZqPuHjGaJLVtoP2uitVGLvVMCUuRAVqvrS_GLcOZpOPPKADpQWdYXq67Q5uZEFLswDRPqDtJpkWSXVB7T8qVNj8KK78qNK2qmOw64wa1wVdiJiQtGYPG7bWFVFOunggGqmQiJilo4lXyd_bUj-p8gEgwxh1fA19IH-CdjuvJ3C4G385D7Jsz8s9y_nWx6xezvszb5BJBb1hM10mlv1Ii5Q9RktWOqbaMi3cfJ6w1f8gd261uiyhz2jz_RUbYZ5yX78Q_J1k08xM-1ycUQIgdoJ4VR15Mf1uuWxh2Qh-JFuS2YuYjuW4Mm8Y0QiFJWMzpMs4_3pM5bvSYtzht635aRJgwsBdpBilFtqygZ7V2U-nFUsXh-py8qitmUgjuJRtwXhWUMmkp6cU9ZQV_o_tetoq34vz6MbQ36i92syRh1dzxrUhS6SyuMSciBRhXRhyeJfY58wtjl-U7uipu273Wt2e8dvsbOdYw76Yxs8J_jJ_S2gb4qM2zR6Bqi6_1IaoruzMwwRQpq8W4h5F-1tsj3bvsYltozjtpphz2ZOiRuh5xlxSZVQd-dWUur9zkf2qyXi0aY5cBY06S4hctuuVvdlMuwxpm0gR57lOjdYF62pxbWB8mWxBhtJI-z-o5FMJYgsnmZcWR8i6cc2_zZBWZg6yuR6ffrkZyn356Bnoxd9o1ZSBZl75JQponk0gJ7a9fWIM0B46kOj-I9Mcyht9QpF8Wteokmru7ngcdX9sq93gm0p63ItjF2l5M8ZOy3-lebQ8mRuh8dxg2shufRQsMV_781U2kBeJoiW1nkXF5r1';
    const String serverKey =
        'cbmwoVe-RWagpygIQfDj9N:APA91bFXpGrVlqu84AoRvKeLzyRjIHsZpULErLJm3-TdbBIyncqL68CfUjQzBOsBoXDNs0DX00unVdZ3QpnHNBrHI5ztkasw44mu3_-87SrLIKnGI3PvGGNow39BOEqbK_qlhEf4rvvc';
    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode({
        'message': {
          'token': fcmToken,
          'notification': {
            'body': body,
            'title': title,
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
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
    await sendFCMNotification(
        'New Medication Added', 'Do remember to take ${_nameController.text}.');

    Navigator.of(context).pop();
  }
}
