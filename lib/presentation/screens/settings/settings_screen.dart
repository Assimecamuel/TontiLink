import 'package:flutter/material.dart' hide Text;
import '../../../core/i18n/tonti_text.dart';
import '../../../core/theme/public_palette.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../widgets/common/tonti_card.dart';
import '../../widgets/common/tonti_badge.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/i18n/l10n.dart';

class SettingsScreen extends StatelessWidget {
  final String activeRole;
  final ValueChanged<String> onRoleChanged;

  const SettingsScreen({
    super.key,
    required this.activeRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 28 : 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('Profil & Paramètres'), style: TontiTypography.displayMedium),
              const SizedBox(height: 4),
              Text(
                tr('Gérez votre identité, vos préférences de notification et vos rôles actifs'),
                style: TontiTypography.bodySmall,
              ),
              const SizedBox(height: 24),

              // Carte profil utilisateur
              TontiCard(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: TontiColors.primaryGold,
                      child: Text(AuthController().currentUser?.avatarInitials ?? '', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(spacing: 0, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                              Text(AuthController().currentUser?.fullName ?? '', style: TontiTypography.headingLarge),
                              const SizedBox(width: 10),
                              TontiBadge(label: activeRole, variant: BadgeVariant.gold),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                              [AuthController().currentUser?.phone ?? '', AuthController().currentUser?.email ?? '']
                                  .where((e) => e.isNotEmpty)
                                  .join(' • '),
                              style: TextStyle(color: TontiColors.textSecondary, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(tr('Membre vérifié (KYC Cameroun validé via CNI)'), style: TextStyle(color: TontiColors.successGreen, fontSize: 11.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sélecteur interactif de rôle pour tester les droits UI
              TontiCard(
                padding: const EdgeInsets.all(24),
                hasGoldBorder: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(spacing: 0, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                        const Icon(Icons.shield_outlined, color: TontiColors.primaryGold),
                        const SizedBox(width: 10),
                        Text(tr('Simulation des Rôles & Permissions UI'), style: TontiTypography.headingMedium),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tr('Testez en temps réel l\'adaptation des écrans selon le rôle connecté :'),
                      style: TextStyle(fontSize: 13, color: TontiColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildRoleOption('Président', 'Coordination générale et signature des levées'),
                        _buildRoleOption('Trésorier', 'Saisie des cotisations, caisse et validation des transferts'),
                        _buildRoleOption('Secrétaire', 'Émargement, réunions et procès-verbaux'),
                        _buildRoleOption('Membre Simple', 'Consultation personnelle et paiement de cotisation'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Paramètres d'Apparence & Thème
              TontiCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(spacing: 0, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                        const Icon(Icons.palette_rounded, color: TontiColors.primaryGold),
                        const SizedBox(width: 10),
                        Text(tr('Apparence & Thème Expert'), style: TontiTypography.headingMedium),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tr('Personnalisez l’interface de TontiLink selon vos préférences visuelles ou l’éclairage ambiant :'),
                      style: TextStyle(fontSize: 13, color: TontiColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ListenableBuilder(
                      listenable: ThemeController.instance,
                      builder: (context, _) {
                        final currentMode = ThemeController.instance.mode;
                        final options = <Widget>[
                          _buildThemeOption(
                            title: tr('Clair'),
                            subtitle: tr('Classique & Lumineux'),
                            icon: Icons.light_mode_rounded,
                            isSelected: currentMode == ThemeMode.light,
                            onTap: () => ThemeController.instance.setMode(ThemeMode.light),
                          ),
                          _buildThemeOption(
                            title: tr('Sombre'),
                            subtitle: tr('Confort visuel nuit'),
                            icon: Icons.dark_mode_rounded,
                            isSelected: currentMode == ThemeMode.dark,
                            onTap: () => ThemeController.instance.setMode(ThemeMode.dark),
                          ),
                          _buildThemeOption(
                            title: tr('Système'),
                            subtitle: tr('Automatique'),
                            icon: Icons.brightness_auto_rounded,
                            isSelected: currentMode == ThemeMode.system,
                            onTap: () => ThemeController.instance.setMode(ThemeMode.system),
                          ),
                        ];
                        // Petit écran : les 3 choix s'empilent au lieu de s'écraser.
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 460) {
                              return Column(
                                children: [
                                  for (int i = 0; i < options.length; i++) ...[
                                    if (i > 0) const SizedBox(height: 10),
                                    SizedBox(width: double.infinity, child: options[i]),
                                  ],
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (int i = 0; i < options.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 12),
                                  Expanded(child: options[i]),
                                ],
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Paramètres de notifications
              TontiCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr('Canaux de Notifications'), style: TontiTypography.headingMedium),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      title: Text(tr('Rappels par SMS & WhatsApp'), style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(tr('Recevoir un rappel 48h avant l\'échéance du tour.')),
                      value: true,
                      activeColor: TontiColors.primaryGold,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) {},
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text(tr('Preuves de versement immédiates'), style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(tr('Recevoir le reçu officiel dès l\'encaissement MTN ou Orange.')),
                      value: true,
                      activeColor: TontiColors.primaryGold,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(String role, String desc) {
    final isSelected = activeRole == role;

    return InkWell(
      onTap: () => onRoleChanged(role),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? TontiColors.goldSoft : TontiColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? TontiColors.primaryGold : TontiColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 16,
                  color: isSelected ? TontiColors.darkGold : TontiColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? TontiColors.darkGold : TontiColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(desc, style: TextStyle(fontSize: 11, color: TontiColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? TontiColors.goldSoft : TontiColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? TontiColors.primaryGold : TontiColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: TontiColors.primaryGold.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? TontiColors.darkGold : TontiColors.textSecondary,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? TontiColors.darkGold : TontiColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? TontiColors.darkGold.withOpacity(0.8) : TontiColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

