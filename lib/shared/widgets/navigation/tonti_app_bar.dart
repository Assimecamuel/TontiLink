import 'package:flutter/material.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/datasources/local_tonti_datasource.dart';
import '../common/tonti_button.dart';
import '../common/tonti_badge.dart';

class TontiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onNewTontinePressed;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onSearchPressed;
  final String activeRole;

  const TontiAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onNewTontinePressed,
    this.onNotificationsPressed,
    this.onSearchPressed,
    this.activeRole = 'Président',
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 16),
      decoration: const BoxDecoration(
        color: TontiColors.white,
        border: Border(
          bottom: BorderSide(color: TontiColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Bouton Drawer si Mobile/Tablette
          if (!isDesktop) ...[
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: TontiColors.textPrimary),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Titre de page et fil d'Ariane
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: isDesktop
                      ? TontiTypography.headingLarge
                      : TontiTypography.headingMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TontiTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Recherche rapide (Web Desktop)
          if (isDesktop) ...[
            Container(
              width: 240,
              height: 40,
              decoration: BoxDecoration(
                color: TontiColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: TontiColors.border),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher une tontine, membre...',
                  hintStyle: TextStyle(fontSize: 12, color: TontiColors.textSecondary),
                  prefixIcon: Icon(Icons.search, size: 18, color: TontiColors.textSecondary),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],

          // Badge Rôle Actuel
          if (isDesktop) ...[
            TontiBadge(
              label: 'Mode $activeRole',
              variant: BadgeVariant.gold,
              icon: Icons.shield_outlined,
            ),
            const SizedBox(width: 16),
          ],

          // Notification Bell
          Stack(
            children: [
              IconButton(
                onPressed: onNotificationsPressed,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: TontiColors.textPrimary,
                  size: 24,
                ),
                tooltip: 'Notifications',
              ),
              if (LocalTontiDataSource().myInAppNotifications.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: TontiColors.alertRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 8),

          // Bouton "+ Créer une tontine"
          if (onNewTontinePressed != null) ...[
            if (isDesktop)
              TontiButton(
                label: 'Nouvelle Tontine',
                icon: Icons.add_circle_outline,
                onPressed: onNewTontinePressed,
                height: 40,
              )
            else
              IconButton(
                onPressed: onNewTontinePressed,
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: TontiColors.primaryGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

