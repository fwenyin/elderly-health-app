import 'package:flutter/material.dart';

class Appointments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Appointments"),
        ListTile(
          title: Text("18 August"),
          subtitle: Text("Cardiology\nChangi General Hosp"),
        ),
        ListTile(
          title: Text("18 August"),
          subtitle: Text("Cardiology\nChangi General Hosp"),
        ),
      ],
    );
  }
}
