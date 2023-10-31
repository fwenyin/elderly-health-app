import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/appointment_model.dart';

class AppointmentScreen extends StatefulWidget {
  final Appointment? appointment;

  AppointmentScreen({this.appointment});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _locationController;
  late TextEditingController _departmentController;
  late DateTime _datetime;

  @override
  void initState() {
    super.initState();

    _locationController =
        TextEditingController(text: widget.appointment?.location ?? "");
    _departmentController =
        TextEditingController(text: widget.appointment?.department ?? "");
    _datetime = widget.appointment?.datetime ?? DateTime.now();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.appointment == null ? "Add Appointment" : "Edit Appointment",
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            TextFormField(
              controller: _departmentController,
              decoration: InputDecoration(labelText: 'Department'),
            ),
            SizedBox(height: 16.0),
            ListTile(
              title: Text(
                "${_datetime.toLocal().toString().split(' ')[0]}",
                style: TextStyle(fontSize: 16),
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _datetime,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != _datetime) {
                  setState(() {
                    _datetime = picked;
                  });
                }
              },
            ),
            ElevatedButton(
              onPressed: _saveAppointment,
              child: Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAppointment() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    if (widget.appointment != null) {
      // Update existing appointment
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .doc(widget.appointment!.id)
          .update({
        'location': _locationController.text,
        'department': _departmentController.text,
        'datetime': _datetime,
      });
    } else {
      // Add a new appointment
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .add({
        'location': _locationController.text,
        'department': _departmentController.text,
        'datetime': _datetime,
      });
    }

    Navigator.of(context).pop();
  }
}
