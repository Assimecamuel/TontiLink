import 'package:flutter/material.dart' hide Text;
import '../../../core/i18n/tonti_text.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/mock_tonti_data.dart';
import '../../../models/loan_and_aid_model.dart';
import '../../widgets/common/tonti_card.dart';
import '../../widgets/common/tonti_button.dart';
import '../../widgets/common/tonti_badge.dart';
import '../../../core/network/api_client.dart';
import '../../../data/datasources/local_tonti_datasource.dart';
import '../../../core/i18n/l10n.dart';

class PretsEntraideScreen extends StatefulWidget {
  final String activeRole;

  const PretsEntraideScreen({
    super.key,
    this.activeRole = 'Président',
  });

  @override
  State<PretsEntraideScreen> createState() => _PretsEntraideScreenState();
}

class _PretsEntraideScreenState extends State<PretsEntraideScreen> {
  bool _isSubmittingRequest = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final dataSource = LocalTontiDataSource();
    final activeTid = dataSource.activeTontineId ?? (dataSource.tontines.isNotEmpty ? LocalTontiDataSource.numericId(dataSource.tontines.first.id) : null);

    final loans = dataSource.loans.where((l) {
      if (activeTid == null) return false;
      if (l.tontineId != null && l.tontineId != activeTid) return false;
      return true;
    }).toList();

    final aidEvents = dataSource.aidEvents.where((a) {
      if (activeTid == null) return false;
      if (a.tontineId != null && a.tontineId != activeTid) return false;
      return true;
    }).toList();

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
                      Text(tr('Prêts & Fonds d\'Entraide'), style: TontiTypography.displayMedium),
                      const SizedBox(height: 4),
                      Text(
                        tr('Assistance mutuelle, micro-crédits internes et secours aux membres'),
                        style: TontiTypography.bodySmall,
                      ),
                    ],
                  ),
                  Flexible(
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        TontiButton(
                          label: tr('Demande de secours'),
                          icon: Icons.volunteer_activism,
                          type: TontiButtonType.outline,
                          onPressed: () => _showRequestAidModal(context),
                        ),
                        TontiButton(
                          label: tr('Demander un prêt'),
                          icon: Icons.request_quote,
                          onPressed: () => _showRequestLoanModal(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section 1 : Micro-Prêts Internes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('Prêts en cours & Échéanciers'), style: TontiTypography.headingMedium),
                  TontiBadge(label: tr('Taux contractuel : 2.0%'), variant: BadgeVariant.gold),
                ],
              ),
              const SizedBox(height: 14),

              if (loans.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: TontiColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TontiColors.border),
                  ),
                  child: Text(tr('Aucun prêt en cours pour cette tontine.'), style: TextStyle(color: TontiColors.textSecondary)),
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
                                  child: Icon(Icons.person, color: TontiColors.darkGold, size: 20),
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
                                Text(
                                  Formatters.formatFCFA(loan.amountRequested),
                                  style: TontiTypography.amountMedium.copyWith(color: TontiColors.primaryGold),
                                ),
                                const SizedBox(height: 4),
                                _buildLoanStatusBadge(loan.status),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Barre de remboursement
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tr('Remboursé : {amountRepaid} • Reste dû : {remainingDue}', {'amountRepaid': Formatters.formatFCFA(loan.amountRepaid), 'remainingDue': Formatters.formatFCFA(loan.remainingDue)}),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              tr('Durée : {durationMonths} mois', {'durationMonths': loan.durationMonths}),
                              style: TextStyle(fontSize: 12, color: TontiColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: loan.progressRatio,
                            minHeight: 8,
                            backgroundColor: TontiColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(TontiColors.successGreen),
                          ),
                        ),
                        _loanActions(context, loan),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 28),

              // Section 2 : Secours et Solidarité (Entraide sociale)
              Text(tr('Fonds d\'Assistance Sociale & Solidarité'), style: TontiTypography.headingMedium),
              const SizedBox(height: 14),

              if (aidEvents.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: TontiColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TontiColors.border),
                  ),
                  child: Text(tr('Aucune demande d’aide ou d’entraide pour cette tontine.'), style: TextStyle(color: TontiColors.textSecondary)),
                )
              else
                ...aidEvents.map((aid) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TontiCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(children: [
                     Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: TontiColors.infoSoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.favorite, color: TontiColors.infoBlue, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(spacing: 0, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                                  Text(aid.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                  const SizedBox(width: 8),
                                  TontiBadge(label: aid.typeLabel, variant: BadgeVariant.neutral, isSmall: true),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(tr('Bénéficiaire : {memberName} • {justification}', {'memberName': aid.memberName, 'justification': aid.justification}), style: TontiTypography.bodySmall),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Formatters.formatFCFA(aid.approvedAmount),
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: TontiColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            TontiBadge(
                              label: switch (aid.status) {
                                AidEventStatus.debourse => 'Déboursé',
                                AidEventStatus.valide => 'Validé',
                                AidEventStatus.rejete => 'Rejeté',
                                _ => 'En attente',
                              },
                              variant: aid.status == AidEventStatus.soumis
                                  ? BadgeVariant.neutral
                                  : BadgeVariant.success,
                              isSmall: true,
                            ),
                          ],
                        ),
                      ],
                     ),
                     _aidActions(context, aid),
                    ]),
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

  String _aidTypeFor(String nature) {
    final n = nature.toLowerCase();
    if (n.contains('décès') || n.contains('deces') || n.contains('obsèques')) return 'DECES';
    if (n.contains('mal') || n.contains('médic') || n.contains('medic') || n.contains('santé')) return 'MALADIE';
    if (n.contains('mariage')) return 'MARIAGE';
    if (n.contains('naissance')) return 'NAISSANCE';
    if (n.contains('accident')) return 'ACCIDENT';
    return 'AUTRE';
  }

  bool get _isBureau {
    final u = LocalTontiDataSource().currentUser;
    return u.isPresident || u.isTreasurer;
  }

  /// Taux d'intérêt + type de taux (FIXE / VARIABLE) pour le décaissement (§6.4).
  Future<({double rate, String type})?> _askRate(BuildContext context, {String initialType = 'FIXE'}) {
    final c = TextEditingController();
    var type = initialType;
    return showDialog<({double rate, String type})>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('Décaissement du prêt')),
        content: StatefulBuilder(
          builder: (context, setLocal) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: c,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: tr('Taux (%)')),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                decoration: InputDecoration(labelText: tr('Type de taux')),
                items: [
                  DropdownMenuItem(value: 'FIXE', child: Text(tr('Fixe (mensualités constantes)'))),
                  DropdownMenuItem(value: 'VARIABLE', child: Text(tr('Variable (mensualités dégressives)'))),
                ],
                onChanged: (v) => setLocal(() => type = v ?? 'FIXE'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Annuler'))),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(c.text.replaceAll(',', '.'));
              Navigator.pop(ctx, (v == null || v <= 0) ? null : (rate: v, type: type));
            },
            child: Text(tr('Décaisser')),
          ),
        ],
      ),
    );
  }

  Future<double?> _askNumber(BuildContext context, String title, String label) {
    final c = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Annuler'))),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(c.text.replaceAll(',', '.'));
              Navigator.pop(ctx, (v == null || v <= 0) ? null : v);
            },
            child: Text(tr('Valider')),
          ),
        ],
      ),
    );
  }

  Future<void> _run(BuildContext context, Future<ApiResponse> Function() action, String okMsg) async {
    final res = await action();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res.isOk ? okMsg : (res.message ?? tr('Action refusée par le serveur.'))),
        backgroundColor: res.isOk ? TontiColors.successGreen : TontiColors.alertRed,
      ),
    );
  }

  Widget _smallBtn(String label, VoidCallback onTap, {bool danger = false}) => Padding(
        padding: const EdgeInsets.only(right: 8, top: 10),
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: danger ? TontiColors.alertRed : TontiColors.darkGold,
            visualDensity: VisualDensity.compact,
          ),
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
      );

  Widget _loanActions(BuildContext context, LoanEntity loan) {
    final ds = LocalTontiDataSource();
    final buttons = <Widget>[];
    switch (loan.status) {
      case LoanStatus.enAttente:
        if (_isBureau) {
          buttons.add(_smallBtn(tr('Approuver'), () => _run(context, () => ds.decideLoan(loan.id, approve: true), tr('Demande approuvée.'))));
          buttons.add(_smallBtn(tr('Rejeter'), () => _run(context, () => ds.decideLoan(loan.id, approve: false), tr('Demande rejetée.')), danger: true));
        }
        break;
      case LoanStatus.approuve:
        if (_isBureau) {
          buttons.add(_smallBtn(tr('Décaisser'), () async {
            final choice = await _askRate(context, initialType: loan.rateType);
            if (choice == null || !context.mounted) return;
            await _run(
              context,
              () => ds.disburseLoan(loan.id,
                  amount: loan.amountRequested, rate: choice.rate, typeTaux: choice.type),
              tr('Prêt décaissé.'),
            );
          }));
        }
        break;
      case LoanStatus.enRemboursement:
      case LoanStatus.enRetard:
        buttons.add(_smallBtn(tr('Rembourser'), () async {
          final amt = await _askNumber(context, tr('Remboursement'), tr('Montant (FCFA)'));
          if (amt == null || !context.mounted) return;
          await _run(context, () => ds.repayLoan(loan.id, amount: amt), tr('Remboursement enregistré.'));
        }));
        break;
      default:
        break;
    }
    return buttons.isEmpty ? const SizedBox.shrink() : Wrap(children: buttons);
  }

  Widget _aidActions(BuildContext context, AidEventEntity aid) {
    final ds = LocalTontiDataSource();
    final buttons = <Widget>[];
    if (aid.status == AidEventStatus.soumis && _isBureau) {
      buttons.add(_smallBtn(tr('Valider'), () => _run(context, () => ds.validateAid(aid.id, approve: true), tr('Événement validé.'))));
      buttons.add(_smallBtn(tr('Rejeter'), () => _run(context, () => ds.validateAid(aid.id, approve: false), tr('Événement rejeté.')), danger: true));
    }
    if (aid.status == AidEventStatus.valide) {
      buttons.add(_smallBtn(tr('Contribuer'), () async {
        final amt = await _askNumber(context, tr('Contribution'), tr('Montant (FCFA)'));
        if (amt == null || !context.mounted) return;
        await _run(context, () => ds.contributeAid(aid.id, amount: amt), tr('Contribution enregistrée.'));
      }));
      if (_isBureau) {
        buttons.add(_smallBtn(tr('Décaisser l\'aide'), () async {
          final amt = await _askNumber(context, tr('Décaissement'), tr('Montant (FCFA)'));
          if (amt == null || !context.mounted) return;
          await _run(context, () => ds.disburseAid(aid.id, amount: amt), tr('Aide décaissée.'));
        }));
      }
    }
    return buttons.isEmpty
        ? const SizedBox.shrink()
        : Align(alignment: Alignment.centerLeft, child: Wrap(children: buttons));
  }

  Widget _buildLoanStatusBadge(LoanStatus status) {
    switch (status) {
      case LoanStatus.enRemboursement:
        return TontiBadge(label: tr('En cours'), variant: BadgeVariant.info, isSmall: true);
      case LoanStatus.enAttente:
        return TontiBadge(label: tr('En attente validation'), variant: BadgeVariant.warning, isSmall: true);
      case LoanStatus.solde:
        return TontiBadge(label: tr('Soldé'), variant: BadgeVariant.success, isSmall: true);
      case LoanStatus.enRetard:
        return TontiBadge(label: tr('En retard'), variant: BadgeVariant.danger, isSmall: true);
      default:
        return TontiBadge(label: tr('Traité'), variant: BadgeVariant.neutral, isSmall: true);
    }
  }

  void _showRequestLoanModal(BuildContext context) {
    final amountController = TextEditingController();
    final motifController = TextEditingController();
    final dureeController = TextEditingController();
    var typeTaux = 'FIXE';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('Demande de prêt interne')),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: tr('Montant souhaité (FCFA)'), suffixText: 'FCFA'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: motifController,
                decoration: InputDecoration(labelText: tr('Motif du prêt')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dureeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: tr('Durée souhaitée (mois)'), suffixText: tr('mois')),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setLocal) => DropdownButtonFormField<String>(
                  value: typeTaux,
                  decoration: InputDecoration(labelText: tr('Type de taux')),
                  items: [
                    DropdownMenuItem(value: 'FIXE', child: Text(tr('Fixe (mensualités constantes)'))),
                    DropdownMenuItem(value: 'VARIABLE', child: Text(tr('Variable (mensualités dégressives)'))),
                  ],
                  onChanged: (v) => setLocal(() => typeTaux = v ?? 'FIXE'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Annuler'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: TontiColors.primaryGold),
            onPressed: _isSubmittingRequest
                ? null
                : () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              final motif = motifController.text.trim();
              final duree = int.tryParse(dureeController.text) ?? 0;
              if (amount <= 0 || duree <= 0 || motif.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr('Renseignez le montant, la durée et le motif.')),
                    backgroundColor: TontiColors.alertRed,
                  ),
                );
                return;
              }
              final dataSource = LocalTontiDataSource();
              final adhesionId = dataSource.currentUserAdhesionId;
              if (adhesionId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      tr('Impossible d’identifier votre adhésion auprès du backend. Réessayez après la synchronisation.'),
                    ),
                    backgroundColor: TontiColors.alertRed,
                  ),
                );
                return;
              }


              setState(() => _isSubmittingRequest = true);
              final response = await ApiClient.instance.post('/api/prets/demandes/', {
                'adhesion_id': adhesionId,
                'montant': amount.toInt(),
                'motif': motif,
                'dureeSouhaitee': duree,
                'typeTaux': typeTaux,
              });

              if (!mounted) return;
              setState(() => _isSubmittingRequest = false);
              if (!response.isOk) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      response.message ??
                          tr('La demande de prêt n’a pas été acceptée par le serveur.'),
                    ),
                    backgroundColor: TontiColors.alertRed,
                  ),
                );
                return;
              }
              await dataSource.syncFromBackend();
              if (mounted) setState(() {});
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('Demande de prêt de {amount} soumise au bureau avec succès !', {'amount': Formatters.formatFCFA(amount)})),
                  backgroundColor: TontiColors.successGreen,
                ),
              );
            },
            child: Text(tr('Soumettre la demande'), style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRequestAidModal(BuildContext context) {
    final natureController = TextEditingController();
    final amountController = TextEditingController();
    final justifController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('Demande d\'assistance d\'entraide')),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: natureController,
                decoration: InputDecoration(labelText: tr('Nature de l\'événement (Deuil, Naissance, Santé...)')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: tr('Montant sollicité (FCFA)'), suffixText: 'FCFA'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: justifController,
                decoration: InputDecoration(labelText: tr('Justificatif / Description')),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Annuler'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: TontiColors.primaryGold),
            onPressed: _isSubmittingRequest
                ? null
                : () async {
              final nature = natureController.text.trim();
              final amount = double.tryParse(amountController.text) ?? 0;
              final justif = justifController.text.trim();
              if (amount <= 0 || nature.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr('Renseignez la nature et le montant de la demande.')),
                    backgroundColor: TontiColors.alertRed,
                  ),
                );
                return;
              }
              final dataSource = LocalTontiDataSource();
              final adhesionId = dataSource.currentUserAdhesionId;
              final tontineId = dataSource.primaryTontineId;
              final caisseId = dataSource.caisseIdFor(tontineId, 'SECOURS_ENTRAIDE') ?? dataSource.primaryCaisseId;
              if (adhesionId == null ||
                  tontineId == null ||
                  caisseId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      tr('Impossible d’identifier votre adhésion, la tontine ou la caisse auprès du backend. Réessayez après la synchronisation.'),
                    ),
                    backgroundColor: TontiColors.alertRed,
                  ),
                );
                return;
              }


              setState(() => _isSubmittingRequest = true);
              final response = await ApiClient.instance.post('/api/entraide/evenements/', {
                'tontine_id': tontineId,
                'beneficiaire_adhesion_id': adhesionId,
                'declarePar_adhesion_id': adhesionId,
                'caisse_id': caisseId,
                'type': _aidTypeFor(nature),
                'descriptionLimitee': '$nature - $justif',
                'dateEvenement': DateTime.now().toIso8601String().substring(0, 10),
                'montantCible': amount.toInt(),
              });

              if (!mounted) return;
              setState(() => _isSubmittingRequest = false);
              if (!response.isOk) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      response.message ??
                          tr('La demande d’entraide n’a pas été acceptée par le serveur.'),
                    ),
                    backgroundColor: TontiColors.alertRed,
                  ),
                );
                return;
              }
              await dataSource.syncFromBackend();
              if (mounted) setState(() {});
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('Demande de secours de {amount} enregistrée avec succès !', {'amount': Formatters.formatFCFA(amount)})),
                  backgroundColor: TontiColors.successGreen,
                ),
              );
            },
            child: Text(tr('Valider la demande'), style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
