import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widget/appointment.dart';
import '../widget/daily_feeling.dart';
import '../widget/medication.dart'; 
import 'login.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HOMEPAGE (Daily Entry)'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DailyFeeling(),
            SizedBox(height: 20),

            Expanded(child: MedicationOverview()),
            SizedBox(height: 20),

            Appointments(),
            SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('FAMILY'),
                Text('HEALTH'),
                Text('HOME'),
                Text('FOOD'),
                Text('EXPLORE'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
