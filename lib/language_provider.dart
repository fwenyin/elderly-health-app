import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = Locale('en'); // Default to English

  Locale get currentLocale => _currentLocale;

  // Call this method on the toggle button press
  void switchLocale(String languageCode) {
    _currentLocale = Locale(languageCode);
    notifyListeners(); // Notify all listeners to rebuild with the new locale

    // Save the preference for future app launches
    _saveLocalePreference(languageCode);
  }

  // Load the locale from shared preferences if it exists
  Future<void> loadLocalePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _currentLocale = Locale(languageCode);
      notifyListeners();
    }
  }

  // Save the locale to shared preferences
  Future<void> _saveLocalePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }
}
