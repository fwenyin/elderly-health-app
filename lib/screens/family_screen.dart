import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/app_localizations.dart';
import '../widget/app_bar.dart';
import '../widget/heading_text.dart';
import '../widget/navigation_bar.dart';
import 'add_friend_screen.dart';
import 'friend_detail_screen.dart';
import 'friend_request_screen.dart';

class FamilyPage extends StatefulWidget {
  @override
  _FamilyPageState createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeadingText(AppLocalizations.of(context)!.myFamily),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddFriendPage()),
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.addFriend),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FriendRequestPage()),
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.friendRequests),
                  ),
                ],
              ),
              Expanded(
                child: StreamBuilder(
                  stream: _firestore
                      .collection('users')
                      .doc(_auth
                          .currentUser!.uid) // Using the current user's UID
                      .collection('friends')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final friends = snapshot.data!.docs;
                    List<Widget> friendWidgets = [];
                    for (var friend in friends) {
                      final friendUid = friend['uid'];
                      final friendWidget = FutureBuilder<DocumentSnapshot>(
                        future:
                            _firestore.collection('users').doc(friendUid).get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return ListTile(title: Text('Loading...'));
                          }
                          final friendName = userSnapshot.data!['name'];

                          return FutureBuilder<String>(
                            future: _fetchFriendFeeling(friendUid),
                            builder: (context, feelingSnapshot) {
                              if (!feelingSnapshot.hasData) {
                                return ListTile(
                                    title: Text(friendName),
                                    subtitle: Text('Loading...'));
                              }
                              final friendFeeling = feelingSnapshot.data;
                              return ListTile(
                                title: Text(friendName),
                                subtitle: Text(friendFeeling!),
                                onTap: () {
                                  // Push a new route that displays the friend's detail page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FriendDetailPage(
                                          friendUid: friendUid),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );

                      friendWidgets.add(friendWidget);
                    }

                    return ListView(children: friendWidgets);
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: CustomNavigationBar(currentIndex: 0));
  }

  Future<String> _fetchFriendFeeling(String friendUid) async {
    DocumentSnapshot snapshot = await _firestore
        .collection('users')
        .doc(friendUid)
        .collection('feelings')
        .doc(DateTime.now().toIso8601String().split('T')[0])
        .get();

    if (snapshot.exists && snapshot.data() is Map<String, dynamic>) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return 'Feeling ${data['feeling']}!';
    }

    return AppLocalizations.of(context)!.noRecentUpdates;
  }
}
