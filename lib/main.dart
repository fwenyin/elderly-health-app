import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'l10n/app_localizations.dart';
import 'screens/explore_screen.dart';
import 'screens/family_screen.dart';
import 'screens/food_screen.dart';
import 'screens/health_chatbot_screen.dart';
import 'screens/health_screen.dart';
import 'screens/login_details_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //String? token = await MyFirebaseMessaging.getToken();
  //print('FCM Token: $token');

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en');

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  Future<bool> areUserDetailsRegistered(User? user) async {
    if (user == null) return false;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return userDoc.exists &&
        userDoc.data()!.containsKey('name') &&
        userDoc.data()!.containsKey('age') &&
        userDoc.data()!.containsKey('height') &&
        userDoc.data()!.containsKey('weight');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data != null) {
              return FutureBuilder<bool>(
                future: areUserDetailsRegistered(snapshot.data),
                builder: (context, detailsSnapshot) {
                  if (detailsSnapshot.connectionState == ConnectionState.done) {
                    if (detailsSnapshot.data == true) {
                      return HomePage();
                    } else {
                      return LoginDetailsPage();
                    }
                  }
                  return CircularProgressIndicator();
                },
              );
            } else {
              return LoginPage();
            }
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
        '/ask': (context) => HealthChatbotPage()
      },
    );
  }
}



/*
class MyFirebaseMessaging {
  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}
*/
