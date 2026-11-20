import 'package:flutter/material.dart' hide Text;
import '../../../../core/i18n/tonti_text.dart';
import '../../../../core/theme/tonti_colors.dart';
import '../../../../core/theme/tonti_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/distribution_model.dart';
import '../../../widgets/common/tonti_card.dart';
import '../../../widgets/common/tonti_badge.dart';
import '../../../widgets/common/tonti_button.dart';
import '../../../../core/i18n/l10n.dart';

class UpcomingDistributionBanner extends StatelessWidget {
  final DistributionModel distribution;
  final VoidCallback onPrepareDistribution;

  const UpcomingDistributionBanner({
    super.key,
    required this.distribution,
    required this.onPrepareDistribution,
  });

  @override
  Widget build(BuildContext context) {
    final daysRemaining =
        distribution.scheduledDate.difference(DateTime.now()).inDays;
    final progress = (distribution.availableAmount / distribution.theoreticalAmount)
        .clamp(0.0, 1.0);

    return TontiCard(
      hasGoldBorder: true,
      backgroundColor: TontiColors.surface,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TontiColors.goldSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: TontiColors.primaryGold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('PROCHAINE DISTRIBUTION EN VEDETTE'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: TontiColors.darkGold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        distribution.tontineName,
                        style: TontiTypography.headingMedium,
                      ),
                    ],
                  ),
                ],
              ),
              TontiBadge(
                label: tr('Dans {daysRemaining} jours', {'daysRemaining': daysRemaining}),
                variant: BadgeVariant.gold,
                icon: Icons.calendar_today_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TontiColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TontiColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: TontiColors.primaryGold,
                  child: Text(
                    (distribution.beneficiaryName.trim().length >= 2
                            ? distribution.beneficiaryName.trim().substring(0, 2)
                            : (distribution.beneficiaryName.trim().isEmpty ? '?' : distribution.beneficiaryName.trim()))
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(spacing: 0, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                          Text(
                            distribution.beneficiaryName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: TontiColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TontiBadge(
                            label: tr('Distribution active'),
                            variant: BadgeVariant.neutral,
                            isSmall: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tr('Téléphone : {beneficiaryPhone}', {'beneficiaryPhone': Formatters.formatCameroonPhone(distribution.beneficiaryPhone)}),
                        style: TontiTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tr('Cagnotte à verser'),
                      style: TextStyle(
                        fontSize: 11,
                        color: TontiColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      Formatters.formatFCFA(distribution.netAmount),
                      style: TontiTypography.amountMedium.copyWith(
                        color: TontiColors.primaryGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Jauge de collecte des fonds
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('Collecte des fonds : {availableAmount} / {theoreticalAmount}', {'availableAmount': Formatters.formatFCFA(distribution.availableAmount), 'theoreticalAmount': Formatters.formatFCFA(distribution.theoreticalAmount)}),
                style: TontiTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                tr('{progress}% réuni', {'progress': (progress * 100).toInt()}),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: progress >= 1.0
                      ? TontiColors.successGreen
                      : TontiColors.darkGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: TontiColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? TontiColors.successGreen : TontiColors.primaryGold,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(spacing: 0, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Icon(
                    Icons.security_rounded,
                    size: 16,
                    color: TontiColors.successGreen,
                  ),
                  SizedBox(width: 6),
                  Text(
                    tr('Nécessite la validation conjointe Trésorier & Président'),
                    style: TextStyle(
                      fontSize: 12,
                      color: TontiColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              TontiButton(
                label: tr('Préparer la distribution'),
                icon: Icons.approval,
                onPressed: onPrepareDistribution,
                height: 38,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

