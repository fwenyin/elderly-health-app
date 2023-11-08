import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthReportScreen extends StatefulWidget {
  @override
  _HealthReportScreenState createState() => _HealthReportScreenState();
}

class _HealthReportScreenState extends State<HealthReportScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedMonth;
  List<Map<String, dynamic>> monthlyData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View my Health Logs'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              hint: Text('Month'),
              value: selectedMonth,
              onChanged: (value) {
                setState(() {
                  selectedMonth = value!;
                  _fetchMonthlyData();
                });
              },
              items: [
                // List of months (you can replace or add more as needed)
                DropdownMenuItem(value: "January", child: Text("January")),
                DropdownMenuItem(value: "February", child: Text("February")),
                DropdownMenuItem(value: "March", child: Text("March")),
                // ... (add all months)
              ],
            ),
          ),
          Text('$selectedMonth Report:', style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          Text('Days with Abnormalities'),
          // Dummy container to represent the abnormalities section
          Container(
            height: 100,
            color: Colors.grey[200],
          ),
          SizedBox(height: 20),
          Text('Average Stats'),
          // Dummy container to represent the average stats section
          Container(
            height: 100,
            color: Colors.grey[300],
          ),
          SizedBox(height: 20),
          _buildDateSelector(),
          ListTile(title: Text('Heart Rate')),
          ListTile(title: Text('Blood Pressure')),
          ListTile(title: Text('Others')),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Row(
      children: [
        Text('I want to see'),
        SizedBox(width: 10),
        // Date picker
        ElevatedButton(
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              // Do something with the picked date
              // You can fetch data for this date if needed
            }
          },
          child: Text('Select Date'),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.calendar_today),
          ),
        ),
      ],
    );
  }

  Future<void> _fetchMonthlyData() async {
    if (selectedMonth == null) return;

    String userId = _auth.currentUser!.uid;

    // Constructing the start and end date for the selected month
    DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    DateTime endDate =
        DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('healthLogs')
        .where('timestamp',
            isGreaterThanOrEqualTo: startDate, isLessThan: endDate)
        .get();

    monthlyData =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    setState(() {});
  }
}
