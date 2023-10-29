import 'package:flutter/material.dart';

import '../widget/app_bar.dart';
import '../widget/appointment.dart';
import '../widget/daily_feeling.dart';
import '../widget/medication.dart'; 
import '../widget/navigation_bar.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
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

          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 2),
    );
  }
}
