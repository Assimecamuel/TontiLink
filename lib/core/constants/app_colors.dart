import 'package:flutter/material.dart';

/// Système de couleurs TontiLink conforme aux spécifications FinTech d'Afrique centrale.
/// Dominante Or et Blanc, contrastes élevés, sérénité et prestige.
class AppColors {
  // Palette Or Principal
  static const Color primaryGold = Color(0xFFC99A2E);
  static const Color lightGold = Color(0xFFE9C96B);
  static const Color darkGold = Color(0xFFA57B1B);
  static const Color deepGold = Color(0xFF7A590F);
  static const Color goldLightest = Color(0xFFFBF6EA);
  static const Color goldSoft = Color(0xFFF9F3DF);
  static const Color goldAccent = Color(0xFFD4AF37);

  // Surfaces & Fonds
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F7F3); // Lin / Écru chaud
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF2EFE9);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardSubtle = Color(0xFFFAF9F6);

  // Typographie & Contrastes
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF777777);
  static const Color textMuted = Color(0xFF9AA0A6);
  static const Color textOnGold = Color(0xFFFFFFFF);

  // États & Retours Système
  static const Color successGreen = Color(0xFF21865B);
  static const Color successSoft = Color(0xFFE8F5EE);
  static const Color alertRed = Color(0xFFD64545);
  static const Color alertSoft = Color(0xFFFCE8E8);
  static const Color infoBlue = Color(0xFF3478C8);
  static const Color infoSoft = Color(0xFFEBF3FB);
  static const Color warningOrange = Color(0xFFE67E22);
  static const Color warningSoft = Color(0xFFFDF0E2);

  // Bordures & Séparateurs
  static const Color border = Color(0xFFE8E3D8);
  static const Color borderSubtle = Color(0xFFF0EBE0);
  static const Color divider = Color(0xFFECE7DC);

  // Écosystème de paiement Cameroun
  static const Color mtnYellow = Color(0xFFFFCC00);
  static const Color orangeMoney = Color(0xFFFF6600);
  static const Color cashGreen = Color(0xFF1B8A5A);
  static const Color bankBlue = Color(0xFF1E5BB0);

  // Ombres & Élévations subtiles
  static BoxShadow softShadow = BoxShadow(
    color: const Color(0xFF202124).withOpacity(0.04),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );

  static BoxShadow elevatedShadow = BoxShadow(
    color: const Color(0xFFC99A2E).withOpacity(0.12),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );
}
