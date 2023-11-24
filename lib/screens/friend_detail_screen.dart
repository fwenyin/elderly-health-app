import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namer_app/l10n/app_localizations.dart';

import '../model/activity_model.dart';
import '../model/food_model.dart';
import '../widget/app_bar.dart';
import '../widget/category_tag.dart';
import '../widget/heading_text.dart';

class FriendDetailPage extends StatefulWidget {
  final String friendUid;

  FriendDetailPage({required this.friendUid});

  @override
  _FriendDetailPageState createState() => _FriendDetailPageState();
}

class _FriendDetailPageState extends State<FriendDetailPage> {
  String? _friendName;
  String? _friendAge;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  @override
  void initState() {
    super.initState();
    _fetchFriendDetails();
  }

  Future<void> _fetchFriendDetails() async {
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(widget.friendUid).get();

    if (snapshot.exists && snapshot.data() is Map<String, dynamic>) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _friendName = data['name'];
        _friendAge = data['age'].toString();
      });
    }
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
            if (_friendName != null) Text('${AppLocalizations.of(context)!.name}: $_friendName'),
            SizedBox(height: 10),
            if (_friendAge != null) Text(AppLocalizations.of(context)!.age + ': $_friendAge'),
            SizedBox(height: 50),
            Text(
              AppLocalizations.of(context)!.todaysFood,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              //flex: 5,
              child: StreamBuilder<List<Food>>(
                stream: _getFoods(widget.friendUid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text(AppLocalizations.of(context)!.noFood));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Food food = snapshot.data![index];
                        print(food);
                        return ListTile(
                          title: Text(food.name),
                          subtitle:
                              Text(
                              '${food.kcal} ${AppLocalizations.of(context)!.kcal}, ${food.carbs} ${AppLocalizations.of(context)!.carbs}'),
                          trailing: CategoryTag(food.mealType),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
             AppLocalizations.of(context)!.movement,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<Activity>>(
                stream: _getActivities(widget.friendUid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text(AppLocalizations.of(context)!.noActivities));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Activity activity = snapshot.data![index];
                        return ListTile(
                          title: Text(activity.name),
                          subtitle: Text(formatDuration(context, activity.duration))
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<List<Food>> _getFoods(String friendUid) {
    // Use friendUid to fetch the data for the specified friend
    return _firestore
        .collection('users')
        .doc(friendUid)
        .collection('foods')
        .doc(DateTime.now().toIso8601String().split('T')[0])
        .collection('items')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Food.fromDocument(doc)).toList());
  }

  Stream<List<Activity>> _getActivities(String friendUid) {
    // Use friendUid to fetch the data for the specified friend
    return _firestore
        .collection('users')
        .doc(friendUid)
        .collection('activities')
        .doc(DateTime.now().toIso8601String().split('T')[0])
        .collection('items')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Activity.fromDocument(doc)).toList());
  }
}
