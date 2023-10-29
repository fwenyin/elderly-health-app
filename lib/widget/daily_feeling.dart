import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyFeeling extends StatefulWidget {
  @override
  _DailyFeelingState createState() => _DailyFeelingState();
}

class _DailyFeelingState extends State<DailyFeeling> {
  String _currentFeeling = '';
  String _userName = 'Name of User'; 
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchCurrentFeeling();
    _fetchUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello $_userName'),
        Row(
          children: [
            Text('You feel... $_currentFeeling'),
            ElevatedButton(
              onPressed: () {
                // Reset the feeling when 'Change' is clicked.
                setState(() {
                  _currentFeeling = '';
                });
              },
              child: Text('Change'),
            ),
          ],
        ),
        // Conditionally render the buttons based on _currentFeeling.
        _currentFeeling.isEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFeelingButton('Good'),
                  _buildFeelingButton('Normal'),
                  _buildFeelingButton('Slightly Unwell'),
                  _buildFeelingButton('Unwell'),
                ],
              )
            : Container(),
      ],
    );
  }

  Widget _buildFeelingButton(String feeling) {
    return Flexible(
      fit: FlexFit.tight,
      child: ElevatedButton(
        onPressed: () async {
          // Set the feeling when a button is clicked.
          setState(() {
            _currentFeeling = feeling;
          });

          // Save the feeling to Firestore.
          await _saveFeelingToFirestore(feeling);
        },
        child: Text(feeling),
      ),
    );
  }

  Future<void> _saveFeelingToFirestore(String feeling) async {
    String userId = _auth.currentUser!.uid;

    // Save the feeling to Firestore with the user's ID and the current date as the document ID.
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('feelings')
        .doc(DateTime.now().toIso8601String().split('T')[
            0]) // This will give the format 'YYYY-MM-DD' as the document ID.
        .set({
      'feeling': feeling,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _fetchCurrentFeeling() async {
    String userId = _auth.currentUser!.uid; 

    DocumentSnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('feelings')
        .doc(DateTime.now().toIso8601String().split('T')[0])
        .get();

    if (snapshot.exists && snapshot.data() is Map<String, dynamic>) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _currentFeeling = data['feeling'] ??
            '';
      });
    }
  }

  Future<void> _fetchUserName() async {
    String userId = _auth.currentUser!.uid;

    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(userId).get();

    if (snapshot.exists && snapshot.data() is Map<String, dynamic>) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _userName = data['name'] ??
            'Name of User';
      });
    }
  }
}
