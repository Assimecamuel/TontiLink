# Thème, langue, notifications, responsive

## Thème clair / sombre
- `core/constants/app_colors.dart` : couleurs adaptatives (jeux `AppColors.light` / `AppColors.dark`).
  Règle : `AppColors.white` = texte sur or uniquement ; pour un FOND utiliser `AppColors.surface`.
- `core/theme/app_theme.dart` : `lightTheme` / `darkTheme` construits depuis les mêmes jeux.
- `core/theme/theme_controller.dart` : mode Clair / Sombre / Système (`isEffectiveDark`).
- `core/utils/force_rebuild.dart` : reconstruit tout l'arbre (état conservé) au changement de thème/langue.

## Langue FR / EN
- `tr('Texte français')` : le texte français sert de clé ; l'anglais est dans `core/i18n/l10n_en.dart`.
- `tr('Bonjour {name}', {'name': x})` pour les textes à variables.
- `core/i18n/tonti_text.dart` : remplace `Text` (import `material.dart' hide Text`) et traduit
  automatiquement les chaînes dynamiques (rôles, statuts…).
- Nouveau texte : l'écrire avec `tr('…')` et ajouter sa traduction dans `l10n_en.dart`
  (une clé ne doit apparaître qu'une seule fois : doublon = erreur de compilation).
- Les libellés comparés dans la logique (`role == 'Président'`, filtres) restent français en interne.

## Notifications
- Stockées en modèle + paramètres, traduites à l'affichage ; identifiants par compteur.
- Créées seulement si le serveur accepte l'action ; effacées au changement de compte.
- Nouveau dialogue : `presentation/widgets/common/notifications_dialog.dart`.

## Responsive
- Langue + thème dans la barre du haut (>= 600 px) et dans le menu latéral (mobile).
- Rangées fragiles converties en `Wrap` ; sélecteur de thème empilé sur petit écran.
