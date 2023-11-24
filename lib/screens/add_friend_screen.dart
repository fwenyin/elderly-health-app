import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:namer_app/l10n/app_localizations.dart';
import '../widget/app_bar.dart';
import 'family_screen.dart';

class AddFriendPage extends StatefulWidget {
  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final TextEditingController _phoneController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String friendNumber = '';

  void _addFriend() async {
    // Using Firebase authentication to fetch the UID of the user with the given phone number
    final QuerySnapshot userSnapshot = await _firestore
        .collection('users')
        .where('phone', isEqualTo: friendNumber)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      final friendUid = userSnapshot.docs.first.id;

      // Adding friend request to the friend's collection
      await _firestore
          .collection('users')
          .doc(friendUid)
          .collection('friendRequests')
          .add({
        'fromUid': _auth.currentUser!.uid,
      });

      // Navigate to FamilyPage after successfully adding a friend
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FamilyPage()),
      );
    } else {
      print('User not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            IntlPhoneField(
              controller: _phoneController,
              initialCountryCode: 'SG',
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.friendPhone,
                labelText: AppLocalizations.of(context)!.phone,
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                friendNumber = val.completeNumber;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addFriend,
              child: Text(AppLocalizations.of(context)!.sendRequest),
            ),
          ],
        ),
      ),
    );
  }
}
