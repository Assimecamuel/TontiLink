import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_typography.dart';

/// Thèmes Material de l'application (clair & sombre), construits à partir
/// des mêmes jeux de couleurs que [AppColors] : une seule source de vérité.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(AppColors.light, Brightness.light);
  static ThemeData get darkTheme => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(ColorTokens t, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    // Texte posé sur un fond or : sombre en thème sombre (lisibilité), blanc en clair.
    final onGold = isDark ? const Color(0xFF1A1405) : AppColors.white;
    final gold = isDark ? const Color(0xFFD9B44A) : AppColors.primaryGold;

    OutlineInputBorder outline(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );

    final scheme = (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
      primary: gold,
      onPrimary: onGold,
      primaryContainer: t.goldSoft,
      onPrimaryContainer: t.darkGold,
      secondary: AppColors.lightGold,
      onSecondary: const Color(0xFF1A1405),
      surface: t.surface,
      onSurface: t.textPrimary,
      onSurfaceVariant: t.textSecondary,
      surfaceContainerHighest: t.surfaceMuted,
      surfaceContainerHigh: t.surfaceMuted,
      surfaceContainer: t.cardSubtle,
      surfaceContainerLow: t.cardSubtle,
      surfaceContainerLowest: t.surface,
      error: t.alertRed,
      onError: isDark ? const Color(0xFF1A1405) : AppColors.white,
      outline: t.border,
      outlineVariant: t.borderSubtle,
    );

    final baseText = TextStyle(color: t.textPrimary);

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      brightness: brightness,
      scaffoldBackgroundColor: t.background,
      canvasColor: t.surface,
      primaryColor: gold,
      colorScheme: scheme,
      dividerColor: t.divider,
      hintColor: t.textMuted,
      iconTheme: IconThemeData(color: t.textPrimary),
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
            bodyColor: t.textPrimary,
            displayColor: t.textPrimary,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.surface,
        foregroundColor: t.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        iconTheme: IconThemeData(color: t.textPrimary),
        titleTextStyle: baseText.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: t.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: onGold,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: AppTypography.buttonText,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: onGold,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.textPrimary,
          side: BorderSide(color: t.border, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: AppTypography.buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: t.darkGold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: outline(t.border),
        enabledBorder: outline(t.border),
        focusedBorder: outline(gold, 2),
        errorBorder: outline(t.alertRed),
        focusedErrorBorder: outline(t.alertRed, 2),
        hintStyle: TextStyle(color: t.textMuted, fontSize: 14),
        labelStyle: TextStyle(color: t.textSecondary, fontSize: 14),
        floatingLabelStyle: TextStyle(color: t.darkGold),
        prefixIconColor: t.textSecondary,
        suffixIconColor: t.textSecondary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: t.textPrimary,
          letterSpacing: -0.3,
        ),
        contentTextStyle: TextStyle(fontSize: 14, color: t.textSecondary, height: 1.4),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: t.surface,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: t.surface,
        surfaceTintColor: Colors.transparent,
        textStyle: TextStyle(color: t.textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: t.border),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: t.textPrimary),
        menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll(t.surface)),
      ),
      listTileTheme: ListTileThemeData(
        textColor: t.textPrimary,
        iconColor: t.textSecondary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: t.surface,
        selectedColor: t.goldSoft,
        side: BorderSide(color: t.border),
        labelStyle: TextStyle(color: t.textPrimary, fontSize: 13),
        secondaryLabelStyle: TextStyle(color: t.darkGold, fontSize: 13),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? gold : null,
        ),
        checkColor: WidgetStatePropertyAll(onGold),
        side: BorderSide(color: t.textSecondary, width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? gold : t.textSecondary,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? onGold : t.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? gold : t.surfaceMuted,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: gold),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? t.surfaceMuted : const Color(0xFF2B2A27),
        contentTextStyle: TextStyle(
          color: isDark ? t.textPrimary : AppColors.white,
          fontSize: 14,
        ),
        actionTextColor: AppColors.lightGold,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? t.surfaceMuted : const Color(0xFF2B2A27),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color: isDark ? t.textPrimary : AppColors.white,
          fontSize: 12,
        ),
      ),
      dividerTheme: DividerThemeData(color: t.divider, thickness: 1, space: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: t.surface,
        selectedItemColor: gold,
        unselectedItemColor: t.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
