import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

import '../i18n/l10n.dart';
import '../utils/force_rebuild.dart';

/// Contrôleur du thème (Clair / Sombre / Système).
///
/// Les couleurs de l'application ([AppColors]) lisent [isEffectiveDark] :
/// à chaque changement, tout l'arbre de widgets est reconstruit (sans perdre
/// l'état des écrans) pour que même les widgets `const` se redessinent.
class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._();
  ThemeController._();

  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  /// Vrai si le mode choisi est explicitement « sombre ».
  bool get isDark => _mode == ThemeMode.dark;

  /// Vrai si le thème réellement affiché est sombre (gère le mode Système).
  bool get isEffectiveDark {
    switch (_mode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    }
  }

  /// Alterne entre clair et sombre (le mode « Système » reste disponible
  /// depuis les paramètres via [setMode]).
  void toggle() {
    setMode(isEffectiveDark ? ThemeMode.light : ThemeMode.dark);
  }

  void setMode(ThemeMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    ForceRebuild.run();
  }

  /// À appeler quand le thème du système change (mode Système).
  void onPlatformBrightnessChanged() {
    if (_mode == ThemeMode.system) {
      notifyListeners();
      ForceRebuild.run();
    }
  }

  String get label {
    switch (_mode) {
      case ThemeMode.light:
        return L10n.instance.t('theme_light');
      case ThemeMode.dark:
        return L10n.instance.t('theme_dark');
      case ThemeMode.system:
        return L10n.instance.t('theme_system');
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
