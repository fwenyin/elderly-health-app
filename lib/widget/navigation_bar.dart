import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;

  CustomNavigationBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/family');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/health');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/food');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/explore');
            break;
          case 5:
            Navigator.pushReplacementNamed(context, '/ask');
            break;
        }
      },
      unselectedItemColor: Colors.black,
      selectedItemColor: Colors.black,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.family_restroom, color: Colors.black),
          label: AppLocalizations.of(context)!.family,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital, color: Colors.black),
          label: AppLocalizations.of(context)!.health,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.black),
          label: AppLocalizations.of(context)!.home,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fastfood, color: Colors.black),
          label: AppLocalizations.of(context)!.food,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore, color: Colors.black),
          label: AppLocalizations.of(context)!.explore,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.question_answer, color: Colors.black),
          label: AppLocalizations.of(context)!.ask,
        ),
      ],
    );
  }
}
