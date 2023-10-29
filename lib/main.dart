import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/explore_screen.dart';
import 'screens/family_screen.dart';
import 'screens/food_screen.dart';
import 'screens/health_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            return snapshot.data != null ? HomePage() : LoginPage();
          }
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
      routes: {
        '/family': (context) => FamilyPage(),
        '/health': (context) => HealthPage(),
        '/home': (context) => HomePage(),
        '/food': (context) => FoodPage(),
        '/explore': (context) => ExplorePage(),
      },
    );
  }
}
