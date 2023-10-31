import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/appointment_model.dart';
import '../screens/add_appointment_screen.dart';


class AppointmentOverview extends StatefulWidget {
  @override
  _AppointmentOverviewState createState() => _AppointmentOverviewState();
}

class _AppointmentOverviewState extends State<AppointmentOverview> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Appointments Overview",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Appointment>>(
              stream: _getAppointments(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Appointment> appointments = snapshot.data!;

                  if (appointments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('You have no appointments.'),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      AppointmentScreen()));
                            },
                            child: Text('Add Appointment'),
                          )
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 2),
                        child: Card(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: _buildAppointmentItem(appointment),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error fetching appointments"));
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AppointmentScreen()),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentItem(Appointment appointment) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.5),
      title: Text(
        '${appointment.location}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
          'Department: ${appointment.department}, DateTime: ${appointment.datetime}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AppointmentScreen(
                    appointment: appointment,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteAppointment(appointment.id);
            },
          ),
        ],
      ),
    );
  }

  Stream<List<Appointment>> _getAppointments() {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('appointments')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Appointment.fromDocument(doc)).toList());
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('appointments')
        .doc(appointmentId)
        .delete();
  }
}
