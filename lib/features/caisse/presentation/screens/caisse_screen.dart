import 'package:flutter/material.dart';
import '../../../../core/theme/tonti_colors.dart';
import '../../../../core/theme/tonti_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/caisse_summary.dart';
import '../../../../shared/widgets/common/tonti_card.dart';
import '../../../../shared/widgets/common/tonti_button.dart';
import '../../../../shared/widgets/common/tonti_badge.dart';

class CaisseScreen extends StatelessWidget {
  const CaisseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final caisse = sl.caisseController.caisseSummary;

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
                      Text('Caisse & Comptabilité', style: TontiTypography.displayMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Rapprochement bancaire, trésorerie physique et distinction rigoureuse des fonds',
                        style: TontiTypography.bodySmall,
                      ),
                    ],
                  ),
                  TontiButton(
                    label: 'Nouvelle écriture de caisse',
                    icon: Icons.add_chart,
                    onPressed: () => _showAddEntryModal(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bannières des soldes : Distinction Théorique vs Réellement Disponible
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TontiCard(
                      padding: const EdgeInsets.all(22),
                      hasGoldBorder: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'FONDS RÉELLEMENT DISPONIBLES',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: TontiColors.darkGold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              TontiBadge(label: 'Rapproché & Confirmé', variant: BadgeVariant.success, isSmall: true),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            Formatters.formatFCFA(caisse.totalActualAvailable),
                            style: TontiTypography.amountLarge.copyWith(color: TontiColors.primaryGold),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSubBalance('Espèces (Coffre)', Formatters.formatFCFA(caisse.availableCashBalance), Icons.attach_money),
                              _buildSubBalance('Mobile Money (MTN/OM)', Formatters.formatFCFA(caisse.mobileMoneyBalance), Icons.phone_android),
                              _buildSubBalance('Compte Bancaire', Formatters.formatFCFA(caisse.bankBalance), Icons.account_balance),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 18),
                    Expanded(
                      flex: 2,
                      child: TontiCard(
                        padding: const EdgeInsets.all(22),
                        backgroundColor: TontiColors.background,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SOLDE COMPTABLE THÉORIQUE',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: TontiColors.textSecondary),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              Formatters.formatFCFA(caisse.theoreticalBalance),
                              style: TontiTypography.amountLarge,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Inclut les promesses de cotisations déclarées en attente de versement effectif.',
                              style: TextStyle(fontSize: 11.5, color: TontiColors.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            TontiBadge(
                              label: 'Écart de rapprochement : 0 FCFA',
                              variant: BadgeVariant.info,
                              isSmall: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 28),

              // Journal des écritures récentes
              Text('Dernières écritures comptables', style: TontiTypography.headingMedium),
              const SizedBox(height: 14),

              Container(
                decoration: BoxDecoration(
                  color: TontiColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TontiColors.border),
                ),
                child: Column(
                  children: caisse.recentEntries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: TontiColors.divider)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: entry.isCredit ? TontiColors.successSoft : TontiColors.alertSoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              entry.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                              color: entry.isCredit ? TontiColors.successGreen : TontiColors.alertRed,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                                const SizedBox(height: 2),
                                Text(
                                  'Auteur : ${entry.performedBy} • Réf : ${entry.proofReference}',
                                  style: TontiTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${entry.isCredit ? '+' : '-'}${Formatters.formatFCFA(entry.amount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: entry.isCredit ? TontiColors.successGreen : TontiColors.alertRed,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TontiBadge(
                                label: entry.isReconciled ? 'Rapproché' : 'À valider',
                                variant: entry.isReconciled ? BadgeVariant.success : BadgeVariant.warning,
                                isSmall: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubBalance(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: TontiColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: TontiColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }

  void _showAddEntryModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Ajouter une écriture de caisse'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(decoration: const InputDecoration(labelText: 'Libellé de l\'opération')),
                const SizedBox(height: 12),
                TextFormField(decoration: const InputDecoration(labelText: 'Montant (FCFA)', suffixText: 'FCFA')),
                const SizedBox(height: 12),
                TextFormField(decoration: const InputDecoration(labelText: 'Justificatif / Reçu')),
              ],
            ),
          ),
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Écriture enregistrée avec succès.')),
                );
              },
              child: const Text('Valider l\'écriture'),
            ),
          ],
        );
      },
    );
  }
}

