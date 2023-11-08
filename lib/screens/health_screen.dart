import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widget/app_bar.dart';
import '../widget/navigation_bar.dart';

class HealthPage extends StatefulWidget {
  @override
  _HealthPageState createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController heartRateController = TextEditingController();
  TextEditingController bloodPressureController = TextEditingController();

  List<Map<String, dynamic>> weeklySummary = [];

  @override
  void initState() {
    super.initState();
    _fetchWeeklySummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          SizedBox(height: 20.0),
          _buildHumanFigure(),
          SizedBox(height: 20.0),
          _buildEntryField('HeartRate', heartRateController),
          SizedBox(height: 10.0),
          _buildEntryField('Blood Pressure', bloodPressureController),
          SizedBox(height: 10.0),
          _buildDropdown('Body Ache', ['Back Pain']),
          SizedBox(height: 10.0),
          _buildDropdown('Others', ['Headache']),
          SizedBox(height: 20.0),
          ElevatedButton(
              onPressed: _saveDataToFirestore, child: Text('Log Data')),
          SizedBox(height: 20.0),
          _buildWeeklySummary(),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildHumanFigure() {
    return Container(
      height: 200.0,
      child: Image.asset(
          'lib/asset/human_figure.png'), 
    );
  }

  Widget _buildEntryField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return DropdownButton<String>(
      hint: Text(label),
      onChanged: (value) {
        // Handle selected value
      },
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  Widget _buildWeeklySummary() {
    return Expanded(
      child: Column(
        children: [
          Text('Weekly Health Summary'),
          ...weeklySummary.map((dayData) {
            return ListTile(
              title: Text('Heart Rate: ${dayData['heartRate']}'),
              subtitle: Text('Blood Pressure: ${dayData['bloodPressure']}'),
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _saveDataToFirestore() async {
    String userId = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('healthLogs')
        .doc(DateTime.now().toIso8601String().split('T')[0])
        .set({
      'heartRate': heartRateController.text,
      'bloodPressure': bloodPressureController.text,
      // Add more fields as needed
    });

    // Clear the controllers after saving the data
    heartRateController.clear();
    bloodPressureController.clear();
  }

  Future<void> _fetchWeeklySummary() async {
    String userId = _auth.currentUser!.uid;

    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(Duration(days: 7));

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('healthLogs')
        .where('timestamp',
            isGreaterThanOrEqualTo: startDate, isLessThan: endDate)
        .get();

    weeklySummary =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    setState(() {});
  }
}

