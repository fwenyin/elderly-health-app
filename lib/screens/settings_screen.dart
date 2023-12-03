import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/l10n/app_localizations.dart';
import 'package:namer_app/main.dart';

import '../widget/app_bar.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _userName;
  String? _userAge;
  String? _userProfilePhotoUrl;
  String? _selectedLanguage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_userProfilePhotoUrl != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(_userProfilePhotoUrl!),
                    radius: 50,
                  )
                else
                  Icon(Icons.person, size: 100.0),
                SizedBox(width: 50),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_userName ?? 'Loading name...',
                          style: TextStyle(fontSize: 18)),
                      SizedBox(height: 15),
                      Text(
                          '${AppLocalizations.of(context)!.age}: ${_userAge ?? 'Loading age...'}'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
               
                DropdownButton<String>(
                  value: _selectedLanguage,
                  hint: Text(AppLocalizations.of(context)!.selectLanguage),
                  items: [
                    DropdownMenuItem(child: Text("English"), value: "en"),
                    DropdownMenuItem(child: Text("中文"), value: "zh"),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLanguage = newValue;
                    });
                    if (newValue != null) {
                      MyApp.setLocale(context, Locale(newValue));
                    }
                  },
                ),
              ],
            ),
            Spacer(), // This will push the row of buttons to the end of the available space.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: _editDetails,
                      child: Text(AppLocalizations.of(context)!.editDetails),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: ElevatedButton(
                      onPressed: _logout,
                      child: Text(AppLocalizations.of(context)!.logout),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchUserDetails() async {
    String userId = _auth.currentUser!.uid;
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(userId).get();

    if (snapshot.exists && snapshot.data() is Map<String, dynamic>) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _userName = data['name'];
        _userAge = data['age'].toString();
        _userProfilePhotoUrl = data['profile_picture'];
      });
    }
  }

  void _editDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage()),
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
