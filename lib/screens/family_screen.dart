import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widget/app_bar.dart';
import '../widget/navigation_bar.dart';
import 'add_friend_screen.dart';
import 'friend_request_screen.dart';

class FamilyPage extends StatefulWidget {
  @override
  _FamilyPageState createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  // Firestore instance
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text("My Family"),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddFriendPage()),
                    );
                  },
                  child: Text("Add Friend"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FriendRequestPage()),
                    );
                  },
                  child: Text("Friend Request"),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder(
                stream: _firestore.collection('family').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final familyMembers = snapshot.data!.docs;
                  List<Widget> memberWidgets = [];
                  for (var member in familyMembers) {
                    final memberName = member['name'];
                    final memberActivity = member['activity'];
                    final memberWidget = ListTile(
                      title: Text(memberName),
                      subtitle: Text(memberActivity),
                    );
                    memberWidgets.add(memberWidget);
                  }
                  return ListView(children: memberWidgets);
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 0),
    );
  }
}