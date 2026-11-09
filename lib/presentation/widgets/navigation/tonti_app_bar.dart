import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/public_palette.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/datasources/local_tonti_datasource.dart';
import '../../controllers/auth_controller.dart';
import '../common/public_controls.dart';

/// En-tête des pages principales : fil d'Ariane, titre, bouton « Nouvelle tontine »,
/// notifications, langue, thème et profil (inspiré du modèle eBord, en or & blanc).
class TontiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onNewTontinePressed;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onProfilePressed;
  final String activeRole;

  const TontiAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onNewTontinePressed,
    this.onNotificationsPressed,
    this.onSearchPressed,
    this.onProfilePressed,
    this.activeRole = 'Président',
  });

  @override
  Size get preferredSize => const Size.fromHeight(82);

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final width = MediaQuery.of(context).size.width;
    final wide = width >= 1280;

    final user = AuthController().currentUser;
    final name = user?.fullName ?? '';
    final initial = (user?.avatarInitials ?? 'P').isNotEmpty
        ? (user?.avatarInitials ?? 'P').substring(0, 1)
        : 'P';

    final avatar = InkWell(
      onTap: onProfilePressed,
      borderRadius: BorderRadius.circular(14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: p.goldSoft,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: p.gold.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(color: p.goldText, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: p.text),
                  ),
                  Text(
                    activeRole,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: p.muted),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    final notifCount = LocalTontiDataSource().myInAppNotifications.length;

    final bell = Stack(
      children: [
        IconButton(
          onPressed: onNotificationsPressed,
          icon: Icon(Icons.notifications_none_rounded, color: p.text, size: 25),
          tooltip: 'Notifications',
        ),
        if (notifCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: AppColors.alertRed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$notifCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );

    return Container(
      height: 82,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 30 : 12),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: Row(
        children: [
          if (!isDesktop) ...[
            Builder(
              builder: (ctx) => IconButton(
                icon: Icon(Icons.menu_rounded, color: p.text),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const SizedBox(width: 4),
          ],

          // Fil d'Ariane + titre
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop)
                  Text(
                    '${tr('crumb')} / TONTILINK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: p.goldText,
                    ),
                  ),
                if (isDesktop) const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isDesktop ? 25 : 18,
                    fontWeight: FontWeight.w800,
                    color: p.text,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
          ),

          if (onNewTontinePressed != null && isDesktop) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onNewTontinePressed,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 44,
                  padding: EdgeInsets.symmetric(horizontal: wide ? 18 : 12),
                  decoration: BoxDecoration(
                    gradient: kGoldGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                      if (wide) ...[
                        const SizedBox(width: 8),
                        Text(
                          tr('new_tontine'),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],

          bell,

          if (isDesktop) ...[
            const SizedBox(width: 6),
            const LanguageDropdown(),
            const SizedBox(width: 10),
            const ThemeToggleButton(),
            const SizedBox(width: 16),
          ],
          avatar,
        ],
      ),
    );
  }
}
