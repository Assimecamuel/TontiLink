import 'package:flutter/material.dart';
import '../../../../core/theme/tonti_colors.dart';
import '../../../../core/theme/tonti_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../injection_container.dart';
import '../../../tontines/domain/entities/tontine.dart';
import '../../../cotisations/domain/entities/transaction.dart';
import '../../../../shared/widgets/charts/financial_bar_chart.dart';
import '../../../../shared/widgets/common/tonti_stat_card.dart';
import '../../../../shared/widgets/common/tonti_card.dart';
import '../../../../shared/widgets/common/tonti_button.dart';
import '../../../../shared/widgets/common/tonti_badge.dart';
import '../widgets/upcoming_distribution_banner.dart';
import '../widgets/recent_transactions_table.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToTontines;
  final VoidCallback onNavigateToCotisations;
  final VoidCallback onNavigateToCaisse;
  final VoidCallback onNavigateToReunions;
  final VoidCallback onRecordPaymentRequested;
  final String activeRole;

  const DashboardScreen({
    super.key,
    required this.onNavigateToTontines,
    required this.onNavigateToCotisations,
    required this.onNavigateToCaisse,
    required this.onNavigateToReunions,
    required this.onRecordPaymentRequested,
    required this.activeRole,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedTxnFilter = 'Toutes';

  final List<MonthlyFinancialData> monthlyChartData = const [
    MonthlyFinancialData(month: 'Mai', collected: 2100000, expected: 2400000),
    MonthlyFinancialData(month: 'Juin', collected: 2350000, expected: 2400000),
    MonthlyFinancialData(month: 'Juil', collected: 2400000, expected: 2400000),
    MonthlyFinancialData(month: 'Août', collected: 2200000, expected: 2400000),
    MonthlyFinancialData(month: 'Sept', collected: 2500000, expected: 2500000),
    MonthlyFinancialData(month: 'Oct (En cours)', collected: 1850000, expected: 2500000),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    // Filtrer les transactions
    final filteredTransactions = sl.cotisationsController.transactions.where((txn) {
      if (selectedTxnFilter == 'Cotisations') {
        return txn.type == TransactionType.cotisation;
      } else if (selectedTxnFilter == 'Distributions') {
        return txn.type == TransactionType.distribution;
      } else if (selectedTxnFilter == 'À vérifier') {
        return txn.status == TransactionStatus.aVerifier;
      }
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
              // Alerte contextuelle pour le trésorier / président si des fonds sont en attente
              if (sl.caisseController.caisseSummary.pendingValidationAmount > 0) ...[
                _buildAlertBanner(context),
                const SizedBox(height: 20),
              ],

              // Grille des 4 indicateurs clés (FinTech KPIs)
              _buildMetricsGrid(context, isDesktop),
              const SizedBox(height: 24),

              // Bannière de la prochaine distribution
              UpcomingDistributionBanner(
                distribution: sl.distributionsController.distributions.first,
                onPrepareDistribution: () {
                  _showDistributionPreparationModal(context);
                },
              ),
              const SizedBox(height: 24),

              // Disposition 2 colonnes sur Desktop : Graphique d'évolution + Actions Rapides
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildChartCard(),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: _buildQuickActionsCard(context),
                    ),
                  ],
                )
              else ...[
                _buildQuickActionsCard(context),
                const SizedBox(height: 20),
                _buildChartCard(),
              ],

              const SizedBox(height: 28),

              // Section Transactions récentes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dernières opérations financières',
                        style: TontiTypography.headingMedium,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Historique traçable en direct avec justificatifs et signatures',
                        style: TextStyle(
                          fontSize: 12,
                          color: TontiColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  // Filtres rapides
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip('Toutes'),
                      _buildFilterChip('Cotisations'),
                      _buildFilterChip('Distributions'),
                      _buildFilterChip('À vérifier'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              RecentTransactionsTable(
                transactions: filteredTransactions,
                onTransactionSelected: (txn) => _showTransactionDetailsModal(context, txn),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFD97706),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1 opération en espèces en attente de vérification par le trésorier',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
                Text(
                  'Versement en espèces de ${Formatters.formatFCFA(sl.caisseController.caisseSummary.pendingValidationAmount)} remis lors de la réunion paroissiale.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
          TontiButton(
            label: 'Vérifier maintenant',
            type: TontiButtonType.secondary,
            height: 36,
            onPressed: widget.onNavigateToCotisations,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, bool isDesktop) {
    final cards = [
      TontiStatCard(
        title: 'COTISATIONS CE MOIS',
        value: Formatters.formatFCFA(1850000),
        subtitle: 'Attendu : 2 500 000 FCFA',
        icon: Icons.payments_outlined,
        iconColor: TontiColors.primaryGold,
        iconBgColor: TontiColors.goldSoft,
        trendLabel: '+14%',
        isPositiveTrend: true,
        onTap: widget.onNavigateToCotisations,
      ),
      TontiStatCard(
        title: 'FONDS DISPONIBLES EN CAISSE',
        value: Formatters.formatFCFA(sl.caisseController.caisseSummary.totalActualAvailable),
        subtitle: 'Dont 3.2M MoMo & 1.45M Cash',
        icon: Icons.account_balance_wallet_outlined,
        iconColor: TontiColors.successGreen,
        iconBgColor: TontiColors.successSoft,
        trendLabel: 'Sécurisé',
        isPositiveTrend: true,
        onTap: widget.onNavigateToCaisse,
      ),
      TontiStatCard(
        title: 'TONTINES ACTIVES',
        value: '${sl.tontinesController.tontines.where((t) => t.status == TontineStatus.active).length} Groupes',
        subtitle: '50 membres au total',
        icon: Icons.groups_outlined,
        iconColor: TontiColors.infoBlue,
        iconBgColor: TontiColors.infoSoft,
        trendLabel: '100% à jour',
        isPositiveTrend: true,
        onTap: widget.onNavigateToTontines,
      ),
      TontiStatCard(
        title: 'PROCHAINE ÉCHÉANCE',
        value: 'Dans 4 jours',
        subtitle: 'Tour #7 • Jeanne Ngo Bayi',
        icon: Icons.event_available_outlined,
        iconColor: TontiColors.warningOrange,
        iconBgColor: TontiColors.warningSoft,
        trendLabel: '1.2M FCFA',
        isPositiveTrend: true,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards.map((card) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: card,
          ),
        )).toList(),
      );
    } else {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
        children: cards,
      );
    }
  }

  Widget _buildChartCard() {
    return TontiCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Évolution des collectes (6 derniers mois)',
                    style: TontiTypography.headingMedium,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Suivi comparatif des cotisations encaissées vs engagements attendus',
                    style: TextStyle(fontSize: 12, color: TontiColors.textSecondary),
                  ),
                ],
              ),
              TontiBadge(
                label: 'Taux de succès : 96.4%',
                variant: BadgeVariant.success,
                icon: Icons.check_circle_outline,
              ),
            ],
          ),
          const SizedBox(height: 20),
          FinancialBarChart(data: monthlyChartData),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return TontiCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions rapides & Raccourcis',
            style: TontiTypography.headingMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'Opérations prioritaires selon vos privilèges de gestion',
            style: TextStyle(fontSize: 12, color: TontiColors.textSecondary),
          ),
          const SizedBox(height: 18),
          _buildActionButton(
            icon: Icons.receipt_long,
            iconColor: TontiColors.primaryGold,
            title: 'Enregistrer une cotisation',
            subtitle: 'Saisie espèces ou validation Mobile Money',
            onTap: widget.onRecordPaymentRequested,
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            icon: Icons.groups_3,
            iconColor: TontiColors.infoBlue,
            title: 'Lancer la séance de réunion',
            subtitle: 'Mode présentiel : émargement & collecte directe',
            onTap: widget.onNavigateToReunions,
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            icon: Icons.request_quote_outlined,
            iconColor: TontiColors.successGreen,
            title: 'Gérer la caisse & les prêts',
            subtitle: 'Consulter le solde disponible ou accorder un prêt',
            onTap: widget.onNavigateToCaisse,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: TontiColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: TontiColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: TontiColors.primaryGold.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: TontiColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: TontiColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: TontiColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedTxnFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => selectedTxnFilter = label);
      },
      selectedColor: TontiColors.goldSoft,
      backgroundColor: TontiColors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? TontiColors.darkGold : TontiColors.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? TontiColors.primaryGold : TontiColors.border,
      ),
    );
  }

  void _showTransactionDetailsModal(BuildContext context, Transaction txn) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.receipt, color: TontiColors.primaryGold),
              const SizedBox(width: 10),
              Text('Détails de transaction', style: TontiTypography.headingMedium),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModalRow('Numéro de référence', txn.reference),
                _buildModalRow('Tontine', txn.tontineName),
                _buildModalRow('Membre concerné', txn.memberName),
                _buildModalRow('Type d\'opération', txn.typeLabel),
                _buildModalRow('Montant net', Formatters.formatFCFA(txn.amount), isBold: true),
                _buildModalRow('Moyen de paiement', txn.paymentMethodLabel),
                _buildModalRow('Validé par', txn.validatedBy ?? 'En cours de validation'),
                _buildModalRow('Note interne', txn.note),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fermer'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reçu officiel téléchargé en PDF')),
                );
              },
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Télécharger le reçu PDF'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModalRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: TontiColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isBold ? TontiColors.primaryGold : TontiColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showDistributionPreparationModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.verified_user, color: TontiColors.primaryGold),
              const SizedBox(width: 10),
              Text('Validation de la distribution', style: TontiTypography.headingMedium),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vous préparez le déblocage du Tour #7 pour Mme Jeanne Ngo Bayi.',
                  style: TextStyle(fontSize: 13, color: TontiColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TontiColors.goldSoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: TontiColors.primaryGold.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Montant théorique :', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(Formatters.formatFCFA(1200000), style: TontiTypography.amountSmall),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Mode de versement choisi : MTN Mobile Money (Compte enregistré : +237 699 12 34 56)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Conformément aux statuts de la tontine, le décaissement sera exécuté une fois la signature du Président enregistrée.',
                  style: TextStyle(fontSize: 11.5, color: TontiColors.textSecondary, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Distribution validée avec succès par le bureau')),
                );
              },
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Confirmer la signature et le versement'),
            ),
          ],
        );
      },
    );
  }
}

