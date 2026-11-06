import 'package:flutter/material.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/datasources/local_tonti_datasource.dart';
import '../../../data/mock_tonti_data.dart';
import '../../../models/caisse_model.dart';
import '../../widgets/common/tonti_card.dart';
import '../../widgets/common/tonti_button.dart';
import '../../widgets/common/tonti_badge.dart';

class CaisseScreen extends StatefulWidget {
  final String activeRole;

  const CaisseScreen({
    super.key,
    this.activeRole = 'Président',
  });

  @override
  State<CaisseScreen> createState() => _CaisseScreenState();
}

class _CaisseScreenState extends State<CaisseScreen> {
  String get activeRole => widget.activeRole;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final caisse = MockTontiData.caisseSummary;

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
                  if (activeRole == 'Trésorier' || activeRole == 'Président')
                    TontiButton(
                      label: 'Rapprochement de caisse',
                      icon: Icons.add_chart,
                      onPressed: () => _showAddEntryModal(context),
                    )
                  else if (activeRole == 'Commissaire aux comptes')
                    TontiBadge(
                      label: 'Mode Contrôle & Audit',
                      variant: BadgeVariant.gold,
                      icon: Icons.verified_user,
                    )
                  else
                    TontiBadge(
                      label: 'Consultation Transparente',
                      variant: BadgeVariant.neutral,
                      icon: Icons.visibility,
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Bannières des soldes : Distinction Théorique vs Réellement Disponible
              LayoutBuilder(
                builder: (context, constraints) {
                  final actualCard = TontiCard(
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
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            _buildSubBalance('Espèces (Coffre)', Formatters.formatFCFA(caisse.availableCashBalance), Icons.attach_money),
                            _buildSubBalance('Mobile Money (MTN/OM)', Formatters.formatFCFA(caisse.mobileMoneyBalance), Icons.phone_android),
                            _buildSubBalance('Compte Bancaire', Formatters.formatFCFA(caisse.bankBalance), Icons.account_balance),
                          ],
                        ),
                      ],
                    ),
                  );

                  final theoreticalCard = TontiCard(
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
                        const TontiBadge(
                          label: 'Écart de rapprochement : 0 FCFA',
                          variant: BadgeVariant.info,
                          isSmall: true,
                        ),
                      ],
                    ),
                  );

                  if (constraints.maxWidth >= 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: actualCard),
                        const SizedBox(width: 18),
                        Expanded(flex: 2, child: theoreticalCard),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        actualCard,
                        const SizedBox(height: 16),
                        theoreticalCard,
                      ],
                    );
                  }
                },
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

  /// Rapprochement de caisse (POST /api/finances/caisses/<id>/rapprochements/).
  void _showAddEntryModal(BuildContext context) {
    final amountController = TextEditingController();
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setLocal) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Rapprochement de caisse'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Saisissez le solde réel constaté. Le serveur le compare au solde théorique.',
                    style: TextStyle(fontSize: 12.5, color: TontiColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Solde réel (FCFA)', suffixText: 'FCFA'),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: TontiColors.primaryGold),
                onPressed: saving
                    ? null
                    : () async {
                        final amt = double.tryParse(amountController.text);
                        if (amt == null || amt < 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Saisissez un solde réel valide.')),
                          );
                          return;
                        }
                        setLocal(() => saving = true);
                        final res = await LocalTontiDataSource().reconcileCaisse(amt);
                        if (!context.mounted) return;
                        Navigator.pop(ctx);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res.isOk
                                ? 'Rapprochement enregistré.'
                                : (res.message ?? 'Le serveur a refusé le rapprochement.')),
                            backgroundColor: res.isOk ? TontiColors.successGreen : TontiColors.alertRed,
                          ),
                        );
                      },
                child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }
}
