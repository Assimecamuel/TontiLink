import 'package:flutter/material.dart';
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
                      Text('Prêts & Fonds d\'Entraide', style: TontiTypography.displayMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Assistance mutuelle, micro-crédits internes et secours aux membres',
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
                          label: 'Demande de secours',
                          icon: Icons.volunteer_activism,
                          type: TontiButtonType.outline,
                          onPressed: () => _showRequestAidModal(context),
                        ),
                        TontiButton(
                          label: 'Demander un prêt',
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
                  Text('Prêts en cours & Échéanciers', style: TontiTypography.headingMedium),
                  const TontiBadge(label: 'Taux contractuel : 2.0%', variant: BadgeVariant.gold),
                ],
              ),
              const SizedBox(height: 14),

              if (loans.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: TontiColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TontiColors.border),
                  ),
                  child: const Text('Aucun prêt en cours pour cette tontine.', style: TextStyle(color: TontiColors.textSecondary)),
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
                                  child: const Icon(Icons.person, color: TontiColors.darkGold, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(loan.borrowerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                                    Text('Motif : ${loan.purpose}', style: TontiTypography.bodySmall),
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
                              'Remboursé : ${Formatters.formatFCFA(loan.amountRepaid)} • Reste dû : ${Formatters.formatFCFA(loan.remainingDue)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Durée : ${loan.durationMonths} mois',
                              style: const TextStyle(fontSize: 12, color: TontiColors.textSecondary),
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
                            valueColor: const AlwaysStoppedAnimation<Color>(TontiColors.successGreen),
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
              Text('Fonds d\'Assistance Sociale & Solidarité', style: TontiTypography.headingMedium),
              const SizedBox(height: 14),

              if (aidEvents.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: TontiColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TontiColors.border),
                  ),
                  child: const Text('Aucune demande d’aide ou d’entraide pour cette tontine.', style: TextStyle(color: TontiColors.textSecondary)),
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
                          child: const Icon(Icons.favorite, color: TontiColors.infoBlue, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(aid.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                  const SizedBox(width: 8),
                                  TontiBadge(label: aid.typeLabel, variant: BadgeVariant.neutral, isSmall: true),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('Bénéficiaire : ${aid.memberName} • ${aid.justification}', style: TontiTypography.bodySmall),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Formatters.formatFCFA(aid.approvedAmount),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: TontiColors.textPrimary),
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
        title: const Text('Décaissement du prêt'),
        content: StatefulBuilder(
          builder: (context, setLocal) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: c,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Taux (%)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type de taux'),
                items: const [
                  DropdownMenuItem(value: 'FIXE', child: Text('Fixe (mensualités constantes)')),
                  DropdownMenuItem(value: 'VARIABLE', child: Text('Variable (mensualités dégressives)')),
                ],
                onChanged: (v) => setLocal(() => type = v ?? 'FIXE'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(c.text.replaceAll(',', '.'));
              Navigator.pop(ctx, (v == null || v <= 0) ? null : (rate: v, type: type));
            },
            child: const Text('Décaisser'),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(c.text.replaceAll(',', '.'));
              Navigator.pop(ctx, (v == null || v <= 0) ? null : v);
            },
            child: const Text('Valider'),
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
        content: Text(res.isOk ? okMsg : (res.message ?? 'Action refusée par le serveur.')),
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
          buttons.add(_smallBtn('Approuver', () => _run(context, () => ds.decideLoan(loan.id, approve: true), 'Demande approuvée.')));
          buttons.add(_smallBtn('Rejeter', () => _run(context, () => ds.decideLoan(loan.id, approve: false), 'Demande rejetée.'), danger: true));
        }
        break;
      case LoanStatus.approuve:
        if (_isBureau) {
          buttons.add(_smallBtn('Décaisser', () async {
            final choice = await _askRate(context, initialType: loan.rateType);
            if (choice == null || !context.mounted) return;
            await _run(
              context,
              () => ds.disburseLoan(loan.id,
                  amount: loan.amountRequested, rate: choice.rate, typeTaux: choice.type),
              'Prêt décaissé.',
            );
          }));
        }
        break;
      case LoanStatus.enRemboursement:
      case LoanStatus.enRetard:
        buttons.add(_smallBtn('Rembourser', () async {
          final amt = await _askNumber(context, 'Remboursement', 'Montant (FCFA)');
          if (amt == null || !context.mounted) return;
          await _run(context, () => ds.repayLoan(loan.id, amount: amt), 'Remboursement enregistré.');
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
      buttons.add(_smallBtn('Valider', () => _run(context, () => ds.validateAid(aid.id, approve: true), 'Événement validé.')));
      buttons.add(_smallBtn('Rejeter', () => _run(context, () => ds.validateAid(aid.id, approve: false), 'Événement rejeté.'), danger: true));
    }
    if (aid.status == AidEventStatus.valide) {
      buttons.add(_smallBtn('Contribuer', () async {
        final amt = await _askNumber(context, 'Contribution', 'Montant (FCFA)');
        if (amt == null || !context.mounted) return;
        await _run(context, () => ds.contributeAid(aid.id, amount: amt), 'Contribution enregistrée.');
      }));
      if (_isBureau) {
        buttons.add(_smallBtn('Décaisser l\'aide', () async {
          final amt = await _askNumber(context, 'Décaissement', 'Montant (FCFA)');
          if (amt == null || !context.mounted) return;
          await _run(context, () => ds.disburseAid(aid.id, amount: amt), 'Aide décaissée.');
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
        return const TontiBadge(label: 'En cours', variant: BadgeVariant.info, isSmall: true);
      case LoanStatus.enAttente:
        return const TontiBadge(label: 'En attente validation', variant: BadgeVariant.warning, isSmall: true);
      case LoanStatus.solde:
        return const TontiBadge(label: 'Soldé', variant: BadgeVariant.success, isSmall: true);
      case LoanStatus.enRetard:
        return const TontiBadge(label: 'En retard', variant: BadgeVariant.danger, isSmall: true);
      default:
        return const TontiBadge(label: 'Traité', variant: BadgeVariant.neutral, isSmall: true);
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
        title: const Text('Demande de prêt interne'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Montant souhaité (FCFA)', suffixText: 'FCFA'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: motifController,
                decoration: const InputDecoration(labelText: 'Motif du prêt'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dureeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Durée souhaitée (mois)', suffixText: 'mois'),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setLocal) => DropdownButtonFormField<String>(
                  value: typeTaux,
                  decoration: const InputDecoration(labelText: 'Type de taux'),
                  items: const [
                    DropdownMenuItem(value: 'FIXE', child: Text('Fixe (mensualités constantes)')),
                    DropdownMenuItem(value: 'VARIABLE', child: Text('Variable (mensualités dégressives)')),
                  ],
                  onChanged: (v) => setLocal(() => typeTaux = v ?? 'FIXE'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
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
                  const SnackBar(
                    content: Text('Renseignez le montant, la durée et le motif.'),
                    backgroundColor: TontiColors.alertRed,
                  ),
                );
                return;
              }
              final dataSource = LocalTontiDataSource();
              final adhesionId = dataSource.currentUserAdhesionId;
              if (adhesionId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Impossible d’identifier votre adhésion auprès du backend. Réessayez après la synchronisation.',
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
                          'La demande de prêt n’a pas été acceptée par le serveur.',
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
                  content: Text('Demande de prêt de ${Formatters.formatFCFA(amount)} soumise au bureau avec succès !'),
                  backgroundColor: TontiColors.successGreen,
                ),
              );
            },
            child: const Text('Soumettre la demande', style: TextStyle(color: Colors.white)),
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
        title: const Text('Demande d\'assistance d\'entraide'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: natureController,
                decoration: const InputDecoration(labelText: 'Nature de l\'événement (Deuil, Naissance, Santé...)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Montant sollicité (FCFA)', suffixText: 'FCFA'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: justifController,
                decoration: const InputDecoration(labelText: 'Justificatif / Description'),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
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
                  const SnackBar(
                    content: Text('Renseignez la nature et le montant de la demande.'),
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
                  const SnackBar(
                    content: Text(
                      'Impossible d’identifier votre adhésion, la tontine ou la caisse auprès du backend. Réessayez après la synchronisation.',
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
                          'La demande d’entraide n’a pas été acceptée par le serveur.',
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
                  content: Text('Demande de secours de ${Formatters.formatFCFA(amount)} enregistrée avec succès !'),
                  backgroundColor: TontiColors.successGreen,
                ),
              );
            },
            child: const Text('Valider la demande', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
