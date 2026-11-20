import 'package:flutter/material.dart' hide Text;

import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/i18n/tonti_text.dart';
import '../../../data/datasources/local_tonti_datasource.dart';

/// Centre de notifications (adapté mobile / tablette / bureau).
///
/// * Les textes sont traduits à l'affichage (changement de langue immédiat).
/// * La liste se met à jour toute seule (abonnement à
///   [LocalTontiDataSource.notificationsRevision]).
/// * Couleurs lues depuis [AppColors] : lisible en thème clair comme sombre.
Future<void> showNotificationsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _NotificationsDialog(),
  );
}

class _NotificationsDialog extends StatelessWidget {
  const _NotificationsDialog();

  @override
  Widget build(BuildContext context) {
    final ds = LocalTontiDataSource();
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 480;

    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 24,
        vertical: compact ? 16 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: size.height * 0.85,
        ),
        child: ValueListenableBuilder<int>(
          valueListenable: ds.notificationsRevision,
          builder: (context, _, __) {
            final notifs = ds.myInAppNotifications;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  hasItems: notifs.isNotEmpty,
                  onClear: ds.clearAllInAppNotifications,
                ),
                Divider(height: 1, color: AppColors.divider),
                Flexible(
                  child: notifs.isEmpty
                      ? const _EmptyState()
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(16),
                          itemCount: notifs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _NotificationTile(
                            data: notifs[i],
                            onRemove: () =>
                                ds.removeInAppNotification(notifs[i]['id'].toString()),
                          ),
                        ),
                ),
                Divider(height: 1, color: AppColors.divider),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkGold,
                          side: const BorderSide(color: AppColors.primaryGold),
                        ),
                        onPressed: ds.simulateExpertNotification,
                        icon: const Icon(Icons.add_alert_rounded, size: 16),
                        label: Text(tr('Simuler alerte')),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(tr('Fermer')),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool hasItems;
  final VoidCallback onClear;
  const _Header({required this.hasItems, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.goldSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.notifications_active_rounded,
                color: AppColors.darkGold, size: 22),
          ),
          const SizedBox(width: 12),
          // Expanded : le titre ne déborde jamais, même sur un petit écran.
          Expanded(
            child: Text(
              tr('Centre de Notifications'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (hasItems)
            TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(foregroundColor: AppColors.alertRed),
              child: Text(
                tr('Tout effacer'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 44, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(
            tr('Aucune nouvelle notification.'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onRemove;
  const _NotificationTile({required this.data, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final type = data['type']?.toString();
    final isPenalty = type == 'PENALITE';
    final args = data['args'] is Map
        ? Map<String, Object?>.from(data['args'] as Map)
        : null;
    final title = tr((data['titre'] ?? 'Notification').toString(), args);
    final message = tr((data['contenu'] ?? '').toString(), args);

    return Dismissible(
      key: ValueKey<String>('notif_${data['id']}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.alertRed,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        decoration: BoxDecoration(
          color: isPenalty ? AppColors.alertSoft : AppColors.cardSubtle,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPenalty
                ? AppColors.alertRed.withOpacity(0.35)
                : AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPenalty
                    ? AppColors.alertRed.withOpacity(0.15)
                    : AppColors.goldSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                switch (type) {
                  'PENALITE' => Icons.gavel_rounded,
                  'COTISATION' => Icons.payments_rounded,
                  'REUNION' => Icons.event_rounded,
                  'TOUR' => Icons.star_rounded,
                  _ => Icons.info_outline_rounded,
                },
                color: isPenalty ? AppColors.alertRed : AppColors.darkGold,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.check_circle_outline_rounded,
                  size: 20, color: AppColors.textMuted),
              tooltip: tr('Marquer comme lue'),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
