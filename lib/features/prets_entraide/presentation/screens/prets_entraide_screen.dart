import 'package:flutter/material.dart';
import '../../../../core/theme/tonti_colors.dart';
import '../../../../core/theme/tonti_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/loan_and_aid.dart';
import '../../../../shared/widgets/common/tonti_card.dart';
import '../../../../shared/widgets/common/tonti_button.dart';
import '../../../../shared/widgets/common/tonti_badge.dart';

class PretsEntraideScreen extends StatefulWidget {
  const PretsEntraideScreen({super.key});

  @override
  State<PretsEntraideScreen> createState() => _PretsEntraideScreenState();
}

class _PretsEntraideScreenState extends State<PretsEntraideScreen> {
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
                      Text('Prêts & Fonds d\'Entraide', style: TontiTypography.displayMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Assistance mutuelle, micro-crédits internes et secours aux membres',
                        style: TontiTypography.bodySmall,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TontiButton(
                        label: 'Demande de secours',
                        icon: Icons.volunteer_activism,
                        type: TontiButtonType.outline,
                        onPressed: () => _showRequestAidModal(context),
                      ),
                      const SizedBox(width: 10),
                      TontiButton(
                        label: 'Demander un prêt',
                        icon: Icons.request_quote,
                        onPressed: () => _showRequestLoanModal(context),
                      ),
                    ],
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

              ...sl.pretsEntraideController.loans.map((loan) {
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
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 28),

              // Section 2 : Secours et Solidarité (Entraide sociale)
              Text('Fonds d\'Assistance Sociale & Solidarité', style: TontiTypography.headingMedium),
              const SizedBox(height: 14),

              ...sl.pretsEntraideController.aidEvents.map((aid) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TontiCard(
                    padding: const EdgeInsets.all(18),
                    child: Row(
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
                              label: aid.status == AidEventStatus.debourse ? 'Déboursé' : 'Validé',
                              variant: BadgeVariant.success,
                              isSmall: true,
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Demande de prêt interne'),
        content: const SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: InputDecoration(labelText: 'Montant souhaité (FCFA)')),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Motif du prêt')),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Durée souhaitée (mois)')),
            ],
          ),
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demande de prêt soumise au bureau !')));
            },
            child: const Text('Soumettre au vote'),
          ),
        ],
      ),
    );
  }

  void _showRequestAidModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Demande d\'assistance d\'entraide'),
        content: const SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: InputDecoration(labelText: 'Nature de l\'événement (Deuil, Naissance...)')),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Montant forfaitaire sollicité')),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Justificatif')),
            ],
          ),
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demande d\'assistance enregistrée !')));
            },
            child: const Text('Valider la demande'),
          ),
        ],
      ),
    );
  }
}

