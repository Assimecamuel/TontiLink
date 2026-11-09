import 'package:flutter/material.dart';

/// Contrôleur du thème expert (Clair / Sombre / Système) avec persistance et options avancées.
class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._();
  ThemeController._();

  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    if (_mode == ThemeMode.light) {
      _mode = ThemeMode.dark;
    } else if (_mode == ThemeMode.dark) {
      _mode = ThemeMode.system;
    } else {
      _mode = ThemeMode.light;
    }
    notifyListeners();
  }

  void setMode(ThemeMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
  }

  String get label {
    switch (_mode) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.system:
        return 'Système';
    }
  }

  IconData get icon {
    switch (_mode) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }
}
