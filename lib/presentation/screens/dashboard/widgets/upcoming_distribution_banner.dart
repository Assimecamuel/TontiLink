import 'package:flutter/material.dart';
import '../../../../core/theme/tonti_colors.dart';
import '../../../../core/theme/tonti_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/distribution_model.dart';
import '../../../widgets/common/tonti_card.dart';
import '../../../widgets/common/tonti_badge.dart';
import '../../../widgets/common/tonti_button.dart';

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
      backgroundColor: TontiColors.white,
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
                      const Text(
                        'PROCHAINE DISTRIBUTION EN VEDETTE',
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
                label: 'Dans $daysRemaining jours',
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
                    distribution.beneficiaryName.substring(0, 2).toUpperCase(),
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
                      Row(
                        children: [
                          Text(
                            distribution.beneficiaryName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: TontiColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TontiBadge(
                            label: 'Distribution active',
                            variant: BadgeVariant.neutral,
                            isSmall: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Téléphone : ${Formatters.formatCameroonPhone(distribution.beneficiaryPhone)}',
                        style: TontiTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Cagnotte à verser',
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
                'Collecte des fonds : ${Formatters.formatFCFA(distribution.availableAmount)} / ${Formatters.formatFCFA(distribution.theoreticalAmount)}',
                style: TontiTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% réuni',
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
              const Row(
                children: [
                  Icon(
                    Icons.security_rounded,
                    size: 16,
                    color: TontiColors.successGreen,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Nécessite la validation conjointe Trésorier & Président',
                    style: TextStyle(
                      fontSize: 12,
                      color: TontiColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              TontiButton(
                label: 'Préparer la distribution',
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

