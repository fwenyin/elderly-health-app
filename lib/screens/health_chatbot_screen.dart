import 'package:flutter/material.dart';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../l10n/app_localizations.dart';
import '../widget/app_bar.dart';
import '../widget/navigation_bar.dart';

class HealthChatbotPage extends StatefulWidget {
  @override
  _HealthChatbotPageState createState() => _HealthChatbotPageState();
}

class _HealthChatbotPageState extends State<HealthChatbotPage> {
  final TextEditingController _symptomController = TextEditingController();
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  List<List<String>> _dataset = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  var message = _messages[index];
                  bool isBot = message["sender"] == "bot";
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      crossAxisAlignment: isBot
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        Text(
                          isBot ? "Health Bot" : "You",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isBot ? Colors.blue : Colors.green,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          padding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isBot ? Colors.blue[100] : Colors.green[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            message["text"]!,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
            padding: EdgeInsets.all(5.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _symptomController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.enterSymptoms,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _getDiagnosis,
                        child: Text(AppLocalizations.of(context)!.ask),
                      ),
              ],
            ),),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 5),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDataset();
    _addInitialBotMessage();
  }

  void _addInitialBotMessage() {
    _messages.add({
      "sender": "bot",
      "text":
          "I am a health advisor bot that can help to provide advice according to your medical symptoms. However, this is not a foolproof professional advice and do seek timely medical attention when necessary. What symptoms do you have today?"
    });
  }

  Future<void> _loadDataset() async {
    _dataset = await readCsvFile('lib/data/preprocessed_medical_kb.csv');
  }

  // Function to read CSV file and return a list of symptom and diagnosis
  Future<List<List<String>>> readCsvFile(String filePath) async {
    final input = await rootBundle.loadString(filePath);
    final fields = const CsvToListConverter()
        .convert(input, fieldDelimiter: ',', eol: '\n');

    // Skip the header row and map the rest to a list of strings
    List<List<String>> symptomDiagnosis = fields.skip(1).map((e) {
      String symptoms = e[4];
      String diagnosis = e[2];
      return [symptoms, diagnosis];
    }).toList();
    return symptomDiagnosis;
  }

// Function to preprocess and tokenize symptoms
  List<String> preprocessSymptoms(String symptoms) {
    return symptoms
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .split(' ');
  }

// Function to calculate TF-IDF and cosine similarity
  Future<String> findMostSimilarDiagnosis(
      String userSymptoms, List<List<String>> dataset) async {
    // Preprocess user symptoms
    List<String> userSymptomsTokens = preprocessSymptoms(userSymptoms);
    // Create a set of all unique tokens
    Set<String> vocabulary = userSymptomsTokens.toSet();
    for (var entry in dataset) {
      vocabulary.addAll(entry[0].split(' '));
    }

    // Create TF (Term Frequency) map
    Map<String, int> wordCount = {};
    vocabulary.forEach((word) => wordCount[word] = 0);
    userSymptomsTokens
        .forEach((word) => wordCount[word] = (wordCount[word] ?? 0) + 1);

    // Calculate TF (Term Frequency)
    List<double> tfUserSymptoms = vocabulary
        .map((word) => wordCount[word]! / userSymptomsTokens.length)
        .toList();

    // Calculate IDF (Inverse Document Frequency)
    List<double> idf = vocabulary.map((word) {
      int containingDocs = 1; // Start with 1 to avoid division by zero
      for (var entry in dataset) {
        if (entry[0].contains(word)) {
          containingDocs++;
        }
      }
      return 1 + log((1 + dataset.length) / containingDocs);
    }).toList();

    // Calculate TF-IDF for user symptoms
    List<double> tfidfUserSymptoms = [];
    for (int i = 0; i < tfUserSymptoms.length; i++) {
      tfidfUserSymptoms.add(tfUserSymptoms[i] * idf[i]);
    }

    // Function to calculate cosine similarity
    double cosineSimilarity(List<double> vec1, List<double> vec2) {
      double dotProduct = 0;
      double normA = 0;
      double normB = 0;
      for (int i = 0; i < vec1.length; i++) {
        dotProduct += vec1[i] * vec2[i];
        normA += pow(vec1[i], 2);
        normB += pow(vec2[i], 2);
      }
      return dotProduct / (sqrt(normA) * sqrt(normB));
    }

    // Compare user symptoms with each entry in the dataset
    double highestSimilarity = 0;
    String mostSimilarDiagnosis = "Not found";
    for (var entry in dataset) {
      List<String> entryTokens = preprocessSymptoms(entry[0]);
      List<double> tfEntry = vocabulary
          .map((word) =>
              entryTokens.where((entryWord) => entryWord == word).length /
              entryTokens.length)
          .toList();
      List<double> tfidfEntry = [];
      for (int i = 0; i < tfEntry.length; i++) {
        tfidfEntry.add(tfEntry[i] * idf[i]);
      }

      // Calculate similarity
      double similarity = cosineSimilarity(tfidfUserSymptoms, tfidfEntry);
      if (similarity > highestSimilarity) {
        highestSimilarity = similarity;
        mostSimilarDiagnosis = entry[1];
      }
    }

    return mostSimilarDiagnosis;
  }

  Future<void> _getDiagnosis() async {
    setState(() {
      _isLoading = true;
    });

    String diagnosis = await findMostSimilarDiagnosis(
      _symptomController.text,
      _dataset,
    );

    setState(() {
      _messages.add({
        "sender": "user",
        "text": _symptomController.text,
      });
      _messages.add({
        "sender": "bot",
        "text": 'I am sorry to hear that. This is what you can do: \n$diagnosis',
      });
      _isLoading = false;
    });

    _symptomController.clear();
  }

  Future<String> translateText(
      String text, String sourceLang, String targetLang) async {
    final response = await http.post(
      Uri.parse("https://libretranslate.com/translate"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "q": text,
        "source": sourceLang,
        "target": targetLang,
        "format": "text",
        "api_key": "" // If you have an API key, include it here
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse['translatedText'];
    } else {
      throw Exception('Failed to translate text');
    }
  }

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }
}
