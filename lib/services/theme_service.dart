import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/board_theme.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal() {
    _loadTheme();
  }

  BoardTheme _currentTheme = BoardTheme.classic;

  BoardTheme get currentTheme => _currentTheme;

  Future<void> setTheme(BoardTheme theme) async {
    _currentTheme = theme;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('board_theme', theme.name);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('board_theme');

    if (themeName != null) {
      final theme = BoardTheme.allThemes.firstWhere(
            (t) => t.name == themeName,
        orElse: () => BoardTheme.classic,
      );
      _currentTheme = theme;
      notifyListeners();
    }
  }
}