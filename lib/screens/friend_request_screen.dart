import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FriendRequestPage extends StatefulWidget {
  @override
  _FriendRequestPageState createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Friend Requests')),
      body: StreamBuilder(
        stream: _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('friendRequests')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          final requests = snapshot.data!.docs;
          List<Widget> requestWidgets = [];
          for (var request in requests) {
            final requesterUid = request['fromUid'];
            final requestId = request.id;

            final requestWidget = FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(requesterUid).get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return ListTile(title: Text('Loading...'));
                }
                final requesterName = snapshot.data!['name'];
                final requesterPhoneNumber = snapshot.data!['phone'];
                return ListTile(
                  leading: Icon(Icons.person), // User Icon
                  title: Text(
                      '$requesterName ($requesterPhoneNumber)'), // Display name and phone number
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          // Accept the friend request
                          // Add friend to current user's friend list using friend's UID as document ID
                          await _firestore
                              .collection('users')
                              .doc(_auth.currentUser!.uid)
                              .collection('friends')
                              .doc(requesterUid)
                              .set({
                            'uid': requesterUid,
                          });

                          // Add current user to the friend's friend list
                          await _firestore
                              .collection('users')
                              .doc(requesterUid)
                              .collection('friends')
                              .doc(_auth.currentUser!.uid)
                              .set({
                            'uid': _auth.currentUser!.uid,
                          });

                          // Remove the friend request after accepting
                          await _firestore
                              .collection('users')
                              .doc(_auth.currentUser!.uid)
                              .collection('friendRequests')
                              .doc(requestId)
                              .delete();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          // Decline the friend request by deleting it
                          await _firestore
                              .collection('users')
                              .doc(_auth.currentUser!.uid)
                              .collection('friendRequests')
                              .doc(requestId)
                              .delete();
                        },
                      ),
                    ],
                  ),
                );
              },
            );

            requestWidgets.add(requestWidget);
          }
          return ListView(children: requestWidgets);
        },
      ),
    );
  }
}