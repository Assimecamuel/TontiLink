import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/public_palette.dart';
import '../../../core/theme/theme_controller.dart';
import 'flag_icon.dart';

/// Bouton de changement de thème : soleil blanc (thème clair) / demi-lune blanche (thème sombre).
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Écoute le thème ET la langue : ce widget est souvent déclaré `const`,
    // Flutter ne le reconstruirait donc jamais sans cet écouteur.
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeController.instance, L10n.instance]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final isDark = ThemeController.instance.isDark;
    return Tooltip(
      message: tr(isDark ? 'theme_to_light' : 'theme_to_dark'),
      child: InkWell(
        onTap: ThemeController.instance.toggle,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: kGoldGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC99A2E).withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: Tween<double>(begin: 0.85, end: 1).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.wb_sunny_rounded,
              key: ValueKey<bool>(isDark),
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

/// Menu déroulant de langue : « FR » + drapeau de la France, « EN » + drapeau de l'Angleterre.
class LanguageDropdown extends StatelessWidget {
  /// Variante pour fond sombre (barre latérale).
  final bool onDark;
  const LanguageDropdown({super.key, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    // Se reconstruit à chaque changement de langue ou de thème, même si le
    // widget parent est `const` (sinon le menu affichait l'ancienne langue).
    return ListenableBuilder(
      listenable: Listenable.merge([L10n.instance, ThemeController.instance]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final p = Pal.of(context);
    final l10n = L10n.instance;

    Widget label(String code, FlagType flag, [Color? color]) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            code,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color ?? p.text),
          ),
          const SizedBox(width: 8),
          FlagIcon(flag: flag),
        ],
      );
    }

    final current = l10n.isFr
        ? label('FR', FlagType.france, onDark ? Colors.white : null)
        : label('EN', FlagType.england, onDark ? Colors.white : null);

    return PopupMenuButton<String>(
      tooltip: tr('lang_label'),
      offset: const Offset(0, 50),
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: p.border),
      ),
      initialValue: l10n.code,
      onSelected: l10n.setLanguage,
      itemBuilder: (_) => [
        PopupMenuItem<String>(value: 'fr', child: label('FR', FlagType.france)),
        PopupMenuItem<String>(value: 'en', child: label('EN', FlagType.england)),
      ],
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: onDark ? Colors.white.withOpacity(0.08) : p.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: onDark ? Colors.white24 : p.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            current,
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: onDark ? Colors.white70 : p.muted),
          ],
        ),
      ),
    );
  }
}

/// Logo TontiLink (pastille or + mot-symbole).
class TontiLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool onDark;
  const TontiLogo({super.key, this.size = 40, this.showText = true, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final p = Pal.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: kGoldGradient,
            borderRadius: BorderRadius.circular(size * 0.3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC99A2E).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.diversity_3_rounded, color: Colors.white, size: size * 0.55),
        ),
        if (showText) ...[
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            text: 'Tonti',
            style: TextStyle(
              fontSize: size * 0.55,
              fontWeight: FontWeight.w800,
              color: onDark ? Colors.white : p.text,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(text: 'Link', style: TextStyle(color: onDark ? AppColors.lightGold : p.gold)),
            ],
          ),
        ),
        ],
      ],
    );
  }
}
