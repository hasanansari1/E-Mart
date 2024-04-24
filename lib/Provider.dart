import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeData _currentTheme;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get currentTheme => _currentTheme;

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isDarkTheme = prefs.getBool('isDarkTheme');
    if (isDarkTheme != null) {
      _currentTheme = isDarkTheme ? ThemeData.dark() : ThemeData.light();
    } else {
      _currentTheme = ThemeData.light(); // Default theme if no preference is found
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _currentTheme =
    (_currentTheme == ThemeData.light()) ? ThemeData.dark() : ThemeData.light();
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _currentTheme == ThemeData.dark());
  }
}
