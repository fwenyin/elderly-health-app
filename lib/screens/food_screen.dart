import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../l10n/app_localizations.dart';
import '../model/food_model.dart';
import '../widget/app_bar.dart';
import '../widget/category_tag.dart';
import '../widget/navigation_bar.dart';

class FoodPage extends StatefulWidget {
  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _foodController = TextEditingController();
  TextEditingController _recipeSearchController = TextEditingController();
  String _selectedMeal = "Breakfast";
  List<Map<String, dynamic>> _youtubeResults = [];

  Future<Map<String, dynamic>?> getNutritionData(String foodName) async {
    final String apiKey = "ro3Ds+IWU199Eb3yeC+AGQ==P8xZ0zFNKqP3xBzo";

    try {
      final response = await http.get(
          Uri.parse(
              'https://api.api-ninjas.com/v1/nutrition?query=${Uri.encodeComponent(foodName)}'),
          headers: {'X-Api-Key': apiKey});

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return {
            'kcal': data[0]['calories'].toDouble(),
            'carbs': data[0]['carbohydrates_total_g'].toDouble()
          };
        } else {
          print('No nutrition data found for the food: $foodName');
          return {'kcal': 0.0, 'carbs': 0.0};
        }
      } else {
        print(
            'Request to nutrition API failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {'kcal': 0.0, 'carbs': 0.0};
      }
    } catch (e) {
      print('An exception occurred while fetching nutrition data: $e');
      return {'kcal': 0.0, 'carbs': 0.0};
    }
  }

  Stream<List<Food>> _getFoods() {
    String userId = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('foods')
        .doc(DateTime.now().toIso8601String().split('T')[0])
        .collection('items')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Food.fromDocument(doc)).toList());
  }

  _addFood() async {
    String userId = _auth.currentUser!.uid;
    String foodName = _foodController.text;
    Map<String, dynamic>? nutritionData = await getNutritionData(foodName);

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('foods')
        .doc(DateTime.now().toIso8601String().split('T')[0])
        .collection('items')
        .add({
      'name': foodName,
      'mealType': _selectedMeal,
      'timestamp': FieldValue.serverTimestamp(),
      'kcal': nutritionData!['kcal'],
      'carbs': nutritionData['carbs']
    });

    _foodController.clear();
  }

  Future<List<Map<String, dynamic>>> searchYouTubeForRecipes(
      String query) async {
    query = '${query}recipe';
    final String serpApiKey =
        '4e87b9bbaaea11d7117577ab448e2f731afc7fc3db689f53e8317748fb576bdd';
    final uri = Uri.parse(
        'https://serpapi.com/search.json?engine=youtube&search_query=$query&api_key=$serpApiKey');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data.containsKey('video_results')) {
          List videos = data['video_results'];
          return videos.map((video) {
            return {
              'title': video['title'],
              'thumbnail': video['thumbnail']['static'],
              'link': video['link'],
            };
          }).toList();
        } else {
          throw Exception('video_results not found in the response');
        }
      } else {
        // Log the response body here to see what the actual error is
        print('Request failed with status: ${response.statusCode}.');
        print('Response body: ${response.body}');
        throw Exception(
            'Failed to fetch YouTube recipes with status code: ${response.statusCode}');
      }
    } on FormatException catch (e) {
      // This will catch JSON parsing errors
      print('The provided string is not valid JSON');
      throw FormatException('The provided string is not valid JSON: $e');
      ;
    } catch (e) {
      // This will catch any other kind of exception
      print('An error occurred: $e');
      throw Exception('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _foodController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.iAte),
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedMeal,
                  items: [
                    DropdownMenuItem(
                        child: Text(AppLocalizations.of(context)!.breakfast), value: "Breakfast"),
                    DropdownMenuItem(child: Text(AppLocalizations.of(context)!.lunch), value: "Lunch"),
                    DropdownMenuItem(child: Text(AppLocalizations.of(context)!.dinner), value: "Dinner")
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMeal = newValue!;
                    });
                  },
                ),
                ElevatedButton(onPressed: _addFood, child: Text(AppLocalizations.of(context)!.add))
              ],
            ),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.todaysFood,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              flex: 5,
              child: StreamBuilder<List<Food>>(
                stream: _getFoods(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text(AppLocalizations.of(context)!.noFood);
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Food food = snapshot.data![index];
                        print(food);
                        return ListTile(
                          title: Text(food.name),
                          subtitle:
                              Text('${food.kcal} ${AppLocalizations.of(context)!.kcal}, ${food.carbs} ${AppLocalizations.of(context)!.carbs}'),
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
              AppLocalizations.of(context)!.learnRecipe,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _recipeSearchController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.wantToMake),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final results = await searchYouTubeForRecipes(
                          _recipeSearchController.text);
                      setState(() {
                        _youtubeResults = results;
                      });
                    } catch (e) {
                      print('Error searching YouTube: $e');
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.search),
                ),
              ],
            ),
            if (_youtubeResults != null && _youtubeResults!.isNotEmpty) ...[
              SizedBox(height: 20),
              Expanded(
                flex: 5,
                child: ListView.builder(
                  itemCount: _youtubeResults!.length,
                  itemBuilder: (context, index) {
                    print('Building item $index');
                    var video = _youtubeResults[index];
                    return ListTile(
                      leading: Image.network(video['thumbnail']),
                      title: Text(video['title']),
                      onTap: () {
                        launchUrl(Uri.parse(video['link']));
                      },
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 3),
    );
  }
}
