import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../model/activity_model.dart';
import '../widget/app_bar.dart';
import '../widget/navigation_bar.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _activityController = TextEditingController();
  TextEditingController _mapSearchController = TextEditingController();
  int _selectedDuration = 30;
  List<Map<String, dynamic>> _googleResults = [];

  String formatDuration(BuildContext context, int duration) {
    var t = AppLocalizations.of(context)!;

    if (duration < 60) {
      return '${duration} ${t.minutes}';
    } else if (duration == 60) {
      return '1 ${t.hour}';
    } else {
      int hours = duration ~/ 60;
      int minutes = duration % 60;
      String hourString =
          hours > 1 ? '${hours} ${t.hours}' : '${hours} ${t.hour}';
      return minutes > 0 ? '$hourString ${minutes} ${t.minutes}' : hourString;
    }
  }

  _addActivity() async {
    String userId = _auth.currentUser!.uid;
    String activityName = _activityController.text;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc(DateTime.now().toIso8601String().split('T')[0])
        .collection('items')
        .add({
      'name': activityName,
      'duration': _selectedDuration,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _activityController.clear();
  }

  Stream<List<Activity>> _getActivities() {
    String userId = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc(DateTime.now().toIso8601String().split('T')[0])
        .collection('items')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Activity.fromDocument(doc)).toList());
  }

  Future<List<Map<String, dynamic>>> searchGoogleMaps(String query) async {
    query = 'exercise near ${query}';
    final String serpApiKey =
        '4e87b9bbaaea11d7117577ab448e2f731afc7fc3db689f53e8317748fb576bdd';
    final response = await http.get(Uri.parse(
        'https://serpapi.com/search.json?engine=google&q=$query&gl=sg&api_key=$serpApiKey'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List places = data['local_results']['places'] as List;

      return places.map((place) {
        return {
          'title': place['title'],
          'address': place['address'],
          'directions': place['directions'],
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch Google maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _activityController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.iDid),
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<int>(
                  value: _selectedDuration,
                  items: [
                    DropdownMenuItem(child: Text("30 " + AppLocalizations.of(context)!.minutes), value: 30),
                    DropdownMenuItem(child: Text("1 " + AppLocalizations.of(context)!.hour), value: 60),
                    DropdownMenuItem(child: Text("1.5 " + AppLocalizations.of(context)!.hours), value: 90),
                    DropdownMenuItem(child: Text("2 " + AppLocalizations.of(context)!.hours), value: 120),
                    DropdownMenuItem(child: Text("2.5 " + AppLocalizations.of(context)!.hours), value: 150),
                    DropdownMenuItem(child: Text("3 " + AppLocalizations.of(context)!.hours), value: 180),
                    DropdownMenuItem(child: Text("3.5 " + AppLocalizations.of(context)!.hours), value: 210),
                    DropdownMenuItem(child: Text("4 " + AppLocalizations.of(context)!.hours), value: 240),
                  ],
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedDuration = newValue!;
                    });
                  },
                ),
                ElevatedButton(onPressed: _addActivity, child: Text(AppLocalizations.of(context)!.add))
              ],
            ),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.movement,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Activity>>(
                stream: _getActivities(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text(AppLocalizations.of(context)!.noActivities);
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Activity activity = snapshot.data![index];
                        return ListTile(
                          title: Text(activity.name),
                          subtitle: Text(formatDuration(context, activity.duration)),
                          // You can add more details or icons here
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.whereExercise,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _mapSearchController,
                    decoration:
                        InputDecoration(labelText: AppLocalizations.of(context)!.postalCode),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final results =
                          await searchGoogleMaps(_mapSearchController.text);
                      setState(() {
                        _googleResults = results;
                      });
                    } catch (e) {
                      print('Error searching YouTube: $e');
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.search),
                ),
              ],
            ),
            if (_googleResults != null && _googleResults.isNotEmpty) ...[
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _googleResults.length,
                  itemBuilder: (context, index) {
                    print('Building item $index');
                    var place = _googleResults[index];
                    return ListTile(
                      leading: Icon(Icons.fitness_center),
                      title: Text(place['title']),
                      subtitle: Text(place['address']),
                      onTap: () {
                        launchUrl(Uri.parse(place['directions']));
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 4),
    );
  }
}
