import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';

/// Jeu de couleurs sémantiques d'un thème (clair ou sombre).
class ColorTokens {
  final Color darkGold, goldLightest, goldSoft;
  final Color background, surface, surfaceMuted, cardSubtle;
  final Color textPrimary, textSecondary, textMuted;
  final Color successGreen, successSoft, alertRed, alertSoft;
  final Color infoBlue, infoSoft, warningOrange, warningSoft;
  final Color warningText, warningBorder;
  final Color border, borderSubtle, divider;
  final Color inputFill;

  const ColorTokens({
    required this.darkGold,
    required this.goldLightest,
    required this.goldSoft,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.cardSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.successGreen,
    required this.successSoft,
    required this.alertRed,
    required this.alertSoft,
    required this.infoBlue,
    required this.infoSoft,
    required this.warningOrange,
    required this.warningSoft,
    required this.warningText,
    required this.warningBorder,
    required this.border,
    required this.borderSubtle,
    required this.divider,
    required this.inputFill,
  });
}

/// Système de couleurs TontiLink (dominante Or & Blanc, thème clair / sombre).
///
/// Les couleurs « sémantiques » (fonds, textes, bordures, états…) sont des
/// *getters* : elles renvoient automatiquement la valeur du thème actif.
/// Les couleurs de marque (or, paiements mobiles) restent identiques dans
/// les deux thèmes.
class AppColors {
  AppColors._();

  static const ColorTokens light = ColorTokens(
    darkGold: Color(0xFFA57B1B),
    goldLightest: Color(0xFFFBF6EA),
    goldSoft: Color(0xFFF9F3DF),
    background: Color(0xFFF8F7F3),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF2EFE9),
    cardSubtle: Color(0xFFFAF9F6),
    textPrimary: Color(0xFF202124),
    textSecondary: Color(0xFF5F6368),
    textMuted: Color(0xFF80868B),
    successGreen: Color(0xFF21865B),
    successSoft: Color(0xFFE8F5EE),
    alertRed: Color(0xFFD64545),
    alertSoft: Color(0xFFFCE8E8),
    infoBlue: Color(0xFF3478C8),
    infoSoft: Color(0xFFEBF3FB),
    warningOrange: Color(0xFFE67E22),
    warningSoft: Color(0xFFFDF0E2),
    warningText: Color(0xFF92400E),
    warningBorder: Color(0xFFFDE68A),
    border: Color(0xFFE8E3D8),
    borderSubtle: Color(0xFFF0EBE0),
    divider: Color(0xFFECE7DC),
    inputFill: Color(0xFFFAF8F3),
  );

  static const ColorTokens dark = ColorTokens(
    darkGold: Color(0xFFE2BE5C),
    goldLightest: Color(0xFF2A2310),
    goldSoft: Color(0xFF332A12),
    background: Color(0xFF14110A),
    surface: Color(0xFF1F1A10),
    surfaceMuted: Color(0xFF2A2316),
    cardSubtle: Color(0xFF251F13),
    textPrimary: Color(0xFFF8F2E2),
    textSecondary: Color(0xFFC4B99F),
    textMuted: Color(0xFF9A917C),
    successGreen: Color(0xFF34B27B),
    successSoft: Color(0xFF14301F),
    alertRed: Color(0xFFF0706E),
    alertSoft: Color(0xFF3A1D1D),
    infoBlue: Color(0xFF6FA8F0),
    infoSoft: Color(0xFF14263A),
    warningOrange: Color(0xFFF2A65A),
    warningSoft: Color(0xFF3A2A14),
    warningText: Color(0xFFF6CB86),
    warningBorder: Color(0xFF5C4515),
    border: Color(0xFF3D3422),
    borderSubtle: Color(0xFF30291A),
    divider: Color(0xFF332B1B),
    inputFill: Color(0xFF2A2316),
  );

  /// Thème sombre actif ? (tient compte du mode « Système »)
  static bool get isDark => ThemeController.instance.isEffectiveDark;

  static ColorTokens get _t => isDark ? dark : light;

  // ── Marque : identiques en clair et en sombre ───────────────────────────
  static const Color primaryGold = Color(0xFFC99A2E);
  static const Color lightGold = Color(0xFFE9C96B);
  static const Color deepGold = Color(0xFF7A590F);
  static const Color goldAccent = Color(0xFFD4AF37);

  /// Or foncé fixe : pour les dégradés / bannières (texte blanc par-dessus).
  static const Color brandDarkGold = Color(0xFFA57B1B);

  /// Blanc pur : texte / icône sur or, rouge, vert… Ne JAMAIS l'utiliser
  /// comme fond : utiliser [surface] à la place.
  static const Color white = Color(0xFFFFFFFF);
  static const Color textOnGold = Color(0xFFFFFFFF);

  // ── Paiement Cameroun (marques : fixes) ─────────────────────────────────
  static const Color mtnYellow = Color(0xFFFFCC00);
  static const Color orangeMoney = Color(0xFFFF6600);
  static const Color cashGreen = Color(0xFF1B8A5A);
  static const Color bankBlue = Color(0xFF1E5BB0);

  // ── Adaptatives (thème clair / sombre) ──────────────────────────────────
  static Color get darkGold => _t.darkGold;
  static Color get goldLightest => _t.goldLightest;
  static Color get goldSoft => _t.goldSoft;

  static Color get background => _t.background;
  static Color get surface => _t.surface;
  static Color get surfaceMuted => _t.surfaceMuted;
  static Color get cardBg => _t.surface;
  static Color get cardSubtle => _t.cardSubtle;

  static Color get textPrimary => _t.textPrimary;
  static Color get textSecondary => _t.textSecondary;
  static Color get textMuted => _t.textMuted;

  static Color get successGreen => _t.successGreen;
  static Color get successSoft => _t.successSoft;
  static Color get alertRed => _t.alertRed;
  static Color get alertSoft => _t.alertSoft;
  static Color get infoBlue => _t.infoBlue;
  static Color get infoSoft => _t.infoSoft;
  static Color get warningOrange => _t.warningOrange;
  static Color get warningSoft => _t.warningSoft;
  static Color get warningText => _t.warningText;
  static Color get warningBorder => _t.warningBorder;

  static Color get border => _t.border;
  static Color get borderSubtle => _t.borderSubtle;
  static Color get divider => _t.divider;

  // ── Ombres ──────────────────────────────────────────────────────────────
  static BoxShadow get softShadow => BoxShadow(
        color: isDark
            ? Colors.black.withOpacity(0.35)
            : const Color(0xFF202124).withOpacity(0.04),
        blurRadius: 16,
        offset: const Offset(0, 4),
      );

  static BoxShadow get elevatedShadow => BoxShadow(
        color: isDark
            ? Colors.black.withOpacity(0.45)
            : const Color(0xFFC99A2E).withOpacity(0.12),
        blurRadius: 24,
        offset: const Offset(0, 8),
      );
}
