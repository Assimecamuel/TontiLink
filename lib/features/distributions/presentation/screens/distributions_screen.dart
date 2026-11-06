import 'package:flutter/material.dart';
import '../../../../core/theme/tonti_colors.dart';
import '../../../../core/theme/tonti_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/distribution.dart';
import '../../../../shared/widgets/common/tonti_card.dart';
import '../../../../shared/widgets/common/tonti_button.dart';
import '../../../../shared/widgets/common/tonti_badge.dart';

class DistributionsScreen extends StatefulWidget {
  final String activeRole;

  const DistributionsScreen({
    super.key,
    required this.activeRole,
  });

  @override
  State<DistributionsScreen> createState() => _DistributionsScreenState();
}

class _DistributionsScreenState extends State<DistributionsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 28 : 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Calendrier des Distributions', style: TontiTypography.displayMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Ordre de passage des bénéficiaires, disponibilité de trésorerie et double signature',
                        style: TontiTypography.bodySmall,
                      ),
                    ],
                  ),
                  TontiBadge(
                    label: 'Double signature active',
                    variant: BadgeVariant.gold,
                    icon: Icons.security,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Liste des distributions
              ...sl.distributionsController.distributions.map((dist) {
                final isCurrent = dist.status == DistributionStatus.enCollecte;
                final isFunded = dist.isFullyFunded;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TontiCard(
                    padding: const EdgeInsets.all(22),
                    hasGoldBorder: isCurrent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: isCurrent ? TontiColors.primaryGold : TontiColors.surfaceMuted,
                                  child: Text(
                                    '#${dist.turnNumber}',
                                    style: TextStyle(
                                      color: isCurrent ? Colors.white : TontiColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(dist.beneficiaryName, style: TontiTypography.headingMedium),
                                        const SizedBox(width: 8),
                                        TontiBadge(
                                          label: dist.statusLabel,
                                          variant: dist.status == DistributionStatus.distribuee
                                              ? BadgeVariant.success
                                              : BadgeVariant.gold,
                                          isSmall: true,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${dist.tontineName} • Échéance : ${dist.scheduledDate.day}/${dist.scheduledDate.month}/${dist.scheduledDate.year}',
                                      style: TontiTypography.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Montant de la cagnotte', style: TextStyle(fontSize: 11, color: TontiColors.textSecondary)),
                                Text(
                                  Formatters.formatFCFA(dist.netAmount),
                                  style: TontiTypography.amountMedium.copyWith(color: TontiColors.primaryGold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Fonds collectés vs théoriques
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: TontiColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: TontiColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Fonds rapprochés disponibles : ${Formatters.formatFCFA(dist.availableAmount)} / ${Formatters.formatFCFA(dist.theoreticalAmount)}',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                              ),
                              if (!isFunded && isCurrent)
                                const Text(
                                  'Alerte : Déficit temporaire de trésorerie',
                                  style: TextStyle(fontSize: 11, color: TontiColors.alertRed, fontWeight: FontWeight.w700),
                                )
                              else if (dist.status == DistributionStatus.distribuee)
                                const Text(
                                  'Décaissé par MTN MoMo',
                                  style: TextStyle(fontSize: 11, color: TontiColors.successGreen, fontWeight: FontWeight.w600),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Statut des signatures
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _buildSignaturePill(
                                  'Président',
                                  dist.approvedByPresident != null,
                                  dist.approvedByPresident,
                                ),
                                const SizedBox(width: 12),
                                _buildSignaturePill(
                                  'Trésorier',
                                  dist.approvedByTreasurer != null,
                                  dist.approvedByTreasurer,
                                ),
                              ],
                            ),
                            if (dist.status == DistributionStatus.enCollecte)
                              TontiButton(
                                label: 'Apposer ma signature & Valider',
                                icon: Icons.check,
                                height: 36,
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Signature apposée ! En attente de la seconde signature.')),
                                  );
                                },
                              )
                            else if (dist.status == DistributionStatus.distribuee)
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.download, size: 16),
                                label: const Text('Reçu officiel PDF'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignaturePill(String role, bool isSigned, String? signer) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSigned ? TontiColors.successSoft : TontiColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSigned ? TontiColors.successGreen.withOpacity(0.3) : TontiColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSigned ? Icons.check_circle : Icons.pending_outlined,
            size: 14,
            color: isSigned ? TontiColors.successGreen : TontiColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            isSigned ? '$role : $signer' : '$role : En attente',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSigned ? TontiColors.successGreen : TontiColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

