import 'package:flutter/material.dart';

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
        }
      },
      unselectedItemColor: Colors.black,
      selectedItemColor: Colors.black,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.family_restroom, color: Colors.black),
          label: 'FAMILY',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital, color: Colors.black),
          label: 'HEALTH',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.black),
          label: 'HOME',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fastfood, color: Colors.black),
          label: 'FOOD',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore, color: Colors.black),
          label: 'EXPLORE',
        ),

      ],
    );
  }
}
