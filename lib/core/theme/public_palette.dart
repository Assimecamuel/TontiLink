import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'theme_controller.dart';

/// Palette Or & Blanc (thème clair) / Or & Noir chaud (thème sombre)
/// utilisée par l'accueil et la connexion.
class Pal {
  final bool dark;
  const Pal._(this.dark);

  /// Détermine le mode sombre selon le contrôleur de thème et le contexte.
  factory Pal.of(BuildContext context) {
    final isDark = ThemeController.instance.isDark ||
        Theme.of(context).brightness == Brightness.dark;
    return Pal._(isDark);
  }

  Color get bg => dark ? const Color(0xFF14110A) : AppColors.background;
  Color get surface => dark ? const Color(0xFF1F1A10) : AppColors.white;
  Color get surfaceAlt => dark ? const Color(0xFF2A2316) : const Color(0xFFFAF8F3);
  Color get border => dark ? const Color(0xFF3D3422) : AppColors.border;
  Color get text => dark ? const Color(0xFFF8F2E2) : AppColors.textPrimary;
  Color get muted => dark ? const Color(0xFFB9AE95) : AppColors.textSecondary;
  Color get gold => dark ? const Color(0xFFD9B44A) : AppColors.primaryGold;
  Color get goldText => dark ? AppColors.lightGold : AppColors.darkGold;
  Color get goldSoft => dark ? const Color(0xFF2E2612) : AppColors.goldLightest;
  Color get navBg => dark ? const Color(0xFF14110A) : AppColors.white;

  List<Color> get heroGradient => dark
      ? const [Color(0xFF2B2209), Color(0xFF14110A)]
      : const [Color(0xFFFFFFFF), Color(0xFFFBF3DC)];

  BoxShadow get shadow => BoxShadow(
        color: dark
            ? Colors.black.withOpacity(0.45)
            : AppColors.primaryGold.withOpacity(0.14),
        blurRadius: 30,
        offset: const Offset(0, 14),
      );
}

/// Dégradé or réutilisable (boutons, pastilles, panneaux).
const LinearGradient kGoldGradient = LinearGradient(
  colors: [AppColors.goldAccent, AppColors.primaryGold, AppColors.darkGold],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
