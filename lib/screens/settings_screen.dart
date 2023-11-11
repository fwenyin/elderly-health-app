import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widget/app_bar.dart';
import 'login_screen.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _userName;
  String? _userAge;

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, size: 55.0),
                SizedBox(width: 30),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_userName ?? 'Loading name...',
                          style: TextStyle(fontSize: 18)),
                      SizedBox(height: 7),   
                      Text('Age: ${_userAge ?? 'Loading age...'}'),
                    ],
                  ),
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
                      child: Text('Edit Details'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: ElevatedButton(
                      onPressed: _logout,
                      /*
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red, // This sets the background color
                      ),
                      */
                      child: Text('Logout'),
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
      });
    }
  }

  void _editDetails() {
    // Navigate to a page to edit user details or open a dialog to edit
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
