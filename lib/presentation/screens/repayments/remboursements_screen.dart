import 'package:flutter/material.dart' hide Text;
import '../../../core/i18n/tonti_text.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/datasources/local_tonti_datasource.dart';
import '../../widgets/common/tonti_card.dart';
import '../../widgets/common/tonti_button.dart';
import '../../widgets/common/tonti_badge.dart';
import '../../../core/i18n/l10n.dart';

class RemboursementsScreen extends StatefulWidget {
  final String activeRole;

  const RemboursementsScreen({
    super.key,
    required this.activeRole,
  });

  @override
  State<RemboursementsScreen> createState() => _RemboursementsScreenState();
}

class _RemboursementsScreenState extends State<RemboursementsScreen> {
  bool _isLoading = false;

  Future<void> _handlePayPenalty(int tontineId, int penaltyId) async {
    setState(() => _isLoading = true);
    final r = await LocalTontiDataSource().payPenalty(tontineId: tontineId, penaltyId: penaltyId);
    await LocalTontiDataSource().syncFromBackend();
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(r.isOk ? tr('Pénalité réglée avec succès ! Vos droits de cotisation sont rétablis.') : (r.message ?? tr('Échec du règlement.'))),
        backgroundColor: r.isOk ? TontiColors.successGreen : TontiColors.alertRed,
      ),
    );
  }

  Future<void> _handleRepayLoan(String loanId, double maxDue) async {
    final amountController = TextEditingController(text: maxDue.toStringAsFixed(0));
    String paymentMethod = 'MOBILE_MONEY';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(tr('Rembourser une échéance de prêt')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('Reste dû : {maxDue}', {'maxDue': Formatters.formatFCFA(maxDue)}), style: const TextStyle(fontWeight: FontWeight.w700, color: TontiColors.primaryGold)),
              const SizedBox(height: 14),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: tr('Montant du remboursement (FCFA)')),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: paymentMethod,
                decoration: InputDecoration(labelText: tr('Mode de paiement')),
                items: [
                  DropdownMenuItem(value: 'MOBILE_MONEY', child: Text(tr('MTN MoMo / Orange Money'))),
                  DropdownMenuItem(value: 'ESPECES', child: Text(tr('Espèces (Séance)'))),
                  DropdownMenuItem(value: 'VIREMENT', child: Text(tr('Virement bancaire'))),
                ],
                onChanged: (v) => setModalState(() => paymentMethod = v ?? 'MOBILE_MONEY'),
              ),
            ],
          ),
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('Annuler'))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: TontiColors.primaryGold),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(tr('Valider le remboursement'), style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;
    final amt = double.tryParse(amountController.text) ?? 0;
    if (amt <= 0) return;

    setState(() => _isLoading = true);
    final r = await LocalTontiDataSource().repayLoan(loanId, amount: amt);
    await LocalTontiDataSource().syncFromBackend();
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(r.isOk ? tr('Remboursement de {amt} enregistré avec succès !', {'amt': Formatters.formatFCFA(amt)}) : (r.message ?? tr('Échec du remboursement.'))),
        backgroundColor: r.isOk ? TontiColors.successGreen : TontiColors.alertRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final dataSource = LocalTontiDataSource();
    final tontines = dataSource.tontines;
    final loans = dataSource.loans;

    final currentUserPhone = dataSource.currentUser.phone;
    final myMembers = <dynamic>[];
    for (final t in tontines) {
      for (final m in t.members) {
        if (m.phone == currentUserPhone || (dataSource.currentUser.id.isNotEmpty && m.id.contains(dataSource.currentUser.id))) {
          myMembers.add({'tontineName': t.name, 'tontineId': LocalTontiDataSource.numericId(t.id), 'member': m});
        }
      }
    }

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
                      Text(tr('Remboursements & Dettes'), style: TontiTypography.displayMedium),
                      const SizedBox(height: 4),
                      Text(
                        tr('Régularisez vos pénalités, remboursez vos prêts et suivez l\'état de vos engagements'),
                        style: TontiTypography.bodySmall,
                      ),
                    ],
                  ),
                  TontiBadge(
                    label: _isLoading ? 'Synchronisation...' : tr('À jour avec le serveur'),
                    variant: BadgeVariant.success,
                    icon: Icons.sync,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(tr('Pénalités & Sanctions en attente'), style: TontiTypography.headingMedium),
              const SizedBox(height: 12),
              if (myMembers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: TontiColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: TontiColors.border)),
                  child: Text(tr('Aucune tontine ou adhésion active trouvée.'), style: TextStyle(color: TontiColors.textSecondary)),
                )
              else
                ...myMembers.map((item) {
                  final tName = item['tontineName'] as String;
                  final tid = item['tontineId'] as int?;
                  final m = item['member'];
                  final hasPenalties = m.unpaidPenaltiesCount > 0 || m.unpaidPenaltiesAmount > 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TontiCard(
                      padding: const EdgeInsets.all(18),
                      hasGoldBorder: hasPenalties,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(spacing: 0, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                                    Text(tName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                    const SizedBox(width: 8),
                                    TontiBadge(
                                      label: hasPenalties ? tr('Pénalité en attente') : tr('Aucune pénalité'),
                                      variant: hasPenalties ? BadgeVariant.danger : BadgeVariant.success,
                                      isSmall: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hasPenalties
                                      ? tr('Montant dû : {unpaidPenaltiesAmount} ({unpaidPenaltiesCount} pénalité(s)). Le paiement lève immédiatement le blocage de vos cotisations.', {'unpaidPenaltiesAmount': Formatters.formatFCFA(m.unpaidPenaltiesAmount), 'unpaidPenaltiesCount': m.unpaidPenaltiesCount})
                                      : tr('Votre situation est parfaitement régie. Aucun impayé de pénalité.'),
                                  style: TontiTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (hasPenalties && tid != null)
                            TontiButton(
                              label: tr('Régler la pénalité'),
                              icon: Icons.payments_outlined,
                              height: 38,
                              onPressed: _isLoading ? null : () => _handlePayPenalty(tid, 1),
                            ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 28),

              Text(tr('Prêts en cours & Échéances'), style: TontiTypography.headingMedium),
              const SizedBox(height: 12),
              if (loans.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: TontiColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: TontiColors.border)),
                  child: Text(tr('Aucun prêt en cours enregistré.'), style: TextStyle(color: TontiColors.textSecondary)),
                )
              else
                ...loans.map((loan) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: TontiCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: TontiColors.goldSoft,
                                    child: Icon(Icons.handshake, color: TontiColors.darkGold, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(loan.borrowerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                                      Text(tr('Motif : {purpose}', {'purpose': loan.purpose}), style: TontiTypography.bodySmall),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(Formatters.formatFCFA(loan.amountRequested), style: TontiTypography.amountMedium.copyWith(color: TontiColors.primaryGold)),
                                  const SizedBox(height: 4),
                                  TontiBadge(label: loan.statusLabel, variant: BadgeVariant.gold, isSmall: true),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tr('Remboursé : {amountRepaid} • Reste dû : {remainingDue}', {'amountRepaid': Formatters.formatFCFA(loan.amountRepaid), 'remainingDue': Formatters.formatFCFA(loan.remainingDue)}),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              TontiButton(
                                label: tr('Rembourser une tranche'),
                                icon: Icons.input,
                                height: 34,
                                onPressed: _isLoading ? null : () => _handleRepayLoan(loan.id, loan.remainingDue),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: loan.progressRatio,
                              minHeight: 8,
                              backgroundColor: TontiColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(TontiColors.successGreen),
                            ),
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
}
