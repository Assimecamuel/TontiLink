import 'package:flutter/material.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/mock_tonti_data.dart';
import '../../../models/tontine_model.dart';
import '../../../models/transaction_model.dart';
import '../../widgets/charts/financial_bar_chart.dart';
import '../../widgets/common/tonti_stat_card.dart';
import '../../widgets/common/tonti_card.dart';
import '../../widgets/common/tonti_button.dart';
import '../../widgets/common/tonti_badge.dart';
import '../../controllers/auth_controller.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../data/datasources/local_tonti_datasource.dart';
import '../../../domain/entities/distribution_entity.dart';
import '../../../domain/entities/member_entity.dart';
import 'widgets/upcoming_distribution_banner.dart';
import 'widgets/recent_transactions_table.dart';

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

  static const List<String> _monthNames = [
    'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc'
  ];

  /// Cotisation attendue par mois = somme (cotisation x membres) des tontines actives.
  double get _expectedPerMonth => MockTontiData.tontines
      .where((t) => t.status == TontineStatus.active)
      .fold<double>(0, (sum, t) => sum + t.contributionAmount * t.memberCount);

  double _collectedIn(int year, int month) => MockTontiData.transactions
      .where((t) =>
          t.type == TransactionType.cotisation &&
          t.status == TransactionStatus.confirme &&
          t.date.year == year &&
          t.date.month == month)
      .fold<double>(0, (sum, t) => sum + t.amount);

  /// Évolution sur 6 mois calculée à partir des cotisations de la base.
  List<MonthlyFinancialData> get monthlyChartData {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final d = DateTime(now.year, now.month - (5 - i), 1);
      return MonthlyFinancialData(
        month: _monthNames[d.month - 1],
        collected: _collectedIn(d.year, d.month),
        expected: _expectedPerMonth,
      );
    });
  }

  /// Prochaine distribution non encore versée (la plus proche).
  DistributionEntity? get _nextDistribution {
    final pending = MockTontiData.distributions
        .where((d) => d.status != DistributionStatus.distribuee)
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return pending.isEmpty ? null : pending.first;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    // Filtrer les transactions
    final filteredTransactions = MockTontiData.transactions.where((txn) {
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
              // Titre de page + bannière de bienvenue (style eBord, en or)
              _buildPageHeading(),
              const SizedBox(height: 22),
              _buildGreetingBanner(context, isDesktop),
              const SizedBox(height: 20),

              // Bannière de rôle statutaire et permissions actives
              _buildRoleStatutoryBanner(context),
              const SizedBox(height: 20),

              // Alerte contextuelle pour le trésorier / président si des fonds sont en attente
              if (MockTontiData.caisseSummary.pendingValidationAmount > 0) ...[
                _buildAlertBanner(context),
                const SizedBox(height: 20),
              ],

              // Grille des 4 indicateurs clés (FinTech KPIs)
              _buildMetricsGrid(context, isDesktop),
              const SizedBox(height: 32),

              // Accès rapides
              _buildQuickAccess(),
              const SizedBox(height: 32),

              // Bannière de la prochaine distribution
              if (_nextDistribution != null) ...[
                UpcomingDistributionBanner(
                  distribution: _nextDistribution!,
                  onPrepareDistribution: () {
                    _showDistributionPreparationModal(context);
                  },
                ),
                const SizedBox(height: 24),
              ],

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


  // ---------------------------------------------------------------------------
  // En-tête de page, bannière de bienvenue et accès rapides (style eBord / or)
  // ---------------------------------------------------------------------------

  Widget _buildPageHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('dash_title'),
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: TontiColors.textPrimary,
            letterSpacing: -0.8,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tr('dash_sub'),
          style: const TextStyle(fontSize: 15, color: TontiColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildGreetingBanner(BuildContext context, bool isDesktop) {
    final fullName = AuthController().currentUser?.fullName ?? 'Paul';
    final firstName = fullName.trim().isEmpty ? 'Paul' : fullName.trim().split(' ').first;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 34 : 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TontiColors.primaryGold, TontiColors.darkGold, TontiColors.deepGold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: TontiColors.primaryGold.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('space_label'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${tr('hello')}, $firstName',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 34 : 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tr('hello_sub'),
                  style: const TextStyle(color: Colors.white, fontSize: 14.5, height: 1.5),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user_outlined, color: Colors.white, size: 15),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${tr('role_connected')} : ${widget.activeRole}',
                          style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 24),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: const Icon(Icons.diversity_3_rounded, color: Colors.white, size: 46),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickAccess() {
    final roleLower = widget.activeRole.toLowerCase();
    final isPresident = roleLower.contains('président') || roleLower.contains('president');
    final isSecretary = roleLower.contains('secrétaire') || roleLower.contains('secretaire');
    final isTreasurer = roleLower.contains('trésorier') || roleLower.contains('tresorier');

    final List<Widget> cards;

    if (isSecretary) {
      cards = [
        _QuickAccessCard(
          icon: Icons.event_available_rounded,
          title: 'Programmer une réunion',
          description: 'Définir la date, lieu et ordre du jour',
          onTap: widget.onNavigateToReunions,
        ),
        _QuickAccessCard(
          icon: Icons.edit_note_rounded,
          title: 'Feuille de présence',
          description: 'Émargement en direct des membres',
          onTap: widget.onNavigateToReunions,
        ),
        _QuickAccessCard(
          icon: Icons.share_rounded,
          title: 'Convocations WhatsApp',
          description: 'Envoyer convocations et rappels',
          onTap: widget.onNavigateToReunions,
        ),
        _QuickAccessCard(
          icon: Icons.warning_amber_rounded,
          title: 'Signaler une pénalité',
          description: 'Enregistrer pénalités de retard',
          onTap: widget.onNavigateToReunions,
        ),
      ];
    } else if (isTreasurer) {
      cards = [
        _QuickAccessCard(
          icon: Icons.fact_check_rounded,
          title: 'Valider les cotisations',
          description: 'Vérifier versements MoMo / Espèces',
          onTap: widget.onNavigateToCotisations,
        ),
        _QuickAccessCard(
          icon: Icons.account_balance_wallet_rounded,
          title: 'Suivi de la Caisse',
          description: 'Contrôler soldes et mouvements',
          onTap: widget.onNavigateToCaisse,
        ),
        _QuickAccessCard(
          icon: Icons.sync_alt_rounded,
          title: 'Préparer distribution',
          description: 'Exécuter le versement aux gagnants',
          onTap: widget.onNavigateToCaisse,
        ),
        _QuickAccessCard(
          icon: Icons.add_alert_rounded,
          title: 'Signaler retard Secrétaire',
          description: 'Transmettre impayés pour pénalités',
          onTap: widget.onNavigateToCotisations,
        ),
      ];
    } else if (!isPresident) {
      // Membre Simple
      cards = [
        _QuickAccessCard(
          icon: Icons.payments_rounded,
          title: 'Cotiser maintenant',
          description: 'Effectuer versement mobile ou espèces',
          onTap: widget.onRecordPaymentRequested,
        ),
        _QuickAccessCard(
          icon: Icons.add_business_rounded,
          title: 'Créer ma tontine & Inviter',
          description: 'Lancer un groupe et inviter des proches',
          onTap: widget.onNavigateToTontines,
        ),
        _QuickAccessCard(
          icon: Icons.handshake_rounded,
          title: 'Demander prêt / aide',
          description: 'Formuler demande de secours ou prêt',
          onTap: widget.onNavigateToCotisations,
        ),
        _QuickAccessCard(
          icon: Icons.notifications_active_rounded,
          title: 'Réunions & Notification',
          description: 'Consulter calendrier et vos rappels',
          onTap: widget.onNavigateToReunions,
        ),
      ];
    } else {
      // Président
      cards = [
        _QuickAccessCard(
          icon: Icons.account_balance_rounded,
          title: tr('qa1_t'),
          description: tr('qa1_d'),
          onTap: widget.onNavigateToTontines,
        ),
        _QuickAccessCard(
          icon: Icons.payments_rounded,
          title: tr('qa2_t'),
          description: tr('qa2_d'),
          onTap: widget.onNavigateToCotisations,
        ),
        _QuickAccessCard(
          icon: Icons.savings_rounded,
          title: tr('qa3_t'),
          description: tr('qa3_d'),
          onTap: widget.onNavigateToCaisse,
        ),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('qa_title'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: TontiColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tr('qa_sub'),
          style: const TextStyle(fontSize: 13.5, color: TontiColors.textSecondary),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth >= 1000 ? 4 : (c.maxWidth >= 560 ? 2 : 1);
            const gap = 16.0;
            final itemW = (c.maxWidth - (cols - 1) * gap) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [for (final card in cards) SizedBox(width: itemW, child: card)],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRoleStatutoryBanner(BuildContext context) {
    UserRole? role = AuthController().currentUser?.activeRole;
    if (widget.activeRole == 'Président') role = UserRole.president;
    if (widget.activeRole == 'Trésorier') role = UserRole.tresorier;
    if (widget.activeRole == 'Secrétaire') role = UserRole.secretaire;
    if (widget.activeRole == 'Commissaire aux comptes' || widget.activeRole == 'Commissaire') role = UserRole.commissaire;
    if (widget.activeRole == 'Membre Simple' || widget.activeRole == 'Membre') role = UserRole.membre;

    String roleTitle = '👑 Mode Président : Habilitation Exécutive Complète';
    String roleDesc =
        'Vous êtes connecté en tant que Président. Conformément au Cahier des charges (Art. 6), vous êtes le seul habilité à attribuer ou modifier les rôles des membres, co-signer les levées et arbitrer les litiges.';
    Color bannerBg = const Color(0xFFFBF6EA);
    Color bannerBorder = const Color(0xFFE9C96B);
    Color iconColor = const Color(0xFFA57B1B);
    IconData icon = Icons.shield_rounded;

    if (role != null) {
      switch (role) {
        case UserRole.president:
          roleTitle = '👑 Mode Président : Habilitation Statutaire Complète';
          roleDesc =
              'Vous avez le pouvoir exclusif d\'attribuer ou modifier les rôles des membres de la tontine, d\'arbitrer les tirages et de co-signer le déblocage des cagnottes.';
          break;
        case UserRole.tresorier:
          roleTitle = '💰 Mode Trésorière : Gestion de Caisse & Rapprochement';
          roleDesc =
              'Vous êtes habilitée à enregistrer les cotisations, rapprocher les comptes MoMo / banque et préparer les distributions. (La modification des rôles des membres est réservée au Président).';
          bannerBg = const Color(0xFFE8F5EE);
          bannerBorder = const Color(0xFF21865B).withOpacity(0.4);
          iconColor = const Color(0xFF21865B);
          icon = Icons.account_balance_wallet;
          break;
        case UserRole.secretaire:
          roleTitle = '📝 Mode Secrétaire : Registres & Assemblées';
          roleDesc =
              'Vous gérez la feuille d\'émargement en direct, rédigez les procès-verbaux et archivez les documents officiels.';
          bannerBg = const Color(0xFFEBF3FB);
          bannerBorder = const Color(0xFF3478C8).withOpacity(0.4);
          iconColor = const Color(0xFF3478C8);
          icon = Icons.edit_note;
          break;
        case UserRole.commissaire:
          roleTitle = '🔍 Mode Commissaire aux Comptes : Audit Indépendant';
          roleDesc =
              'Vous bénéficiez d\'une vue d\'audit complète sur l\'ensemble des écritures et pièces justificatives, sans pouvoir de modification directe.';
          bannerBg = const Color(0xFFF2EFE9);
          bannerBorder = const Color(0xFFE8E3D8);
          iconColor = const Color(0xFF777777);
          icon = Icons.fact_check_outlined;
          break;
        case UserRole.membre:
          roleTitle = '👤 Espace Membre : Consultation & Cotisation';
          roleDesc =
              'Consultez votre tour de passage, effectuez vos cotisations en ligne et soumettez vos demandes de prêt ou d\'assistance sociale.';
          bannerBg = const Color(0xFFFAF8F3);
          bannerBorder = const Color(0xFFE8E3D8);
          iconColor = const Color(0xFFA57B1B);
          icon = Icons.person;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleTitle,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  roleDesc,
                  style: const TextStyle(fontSize: 11.5, color: TontiColors.textPrimary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
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
                  'Versement en espèces de ${Formatters.formatFCFA(MockTontiData.caisseSummary.pendingValidationAmount)} remis lors de la réunion paroissiale.',
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
    final nextDist = _nextDistribution;
    final now = DateTime.now();
    final collectedMonth = _collectedIn(now.year, now.month);
    final totalMembers = MockTontiData.tontines.fold<int>(0, (sum, t) => sum + t.memberCount);
    final daysLeft = nextDist == null ? null : nextDist.scheduledDate.difference(now).inDays;
    final caisse = MockTontiData.caisseSummary;

    final roleLower = widget.activeRole.toLowerCase();
    final isPresident = roleLower.contains('président') || roleLower.contains('president');
    final isSecretary = roleLower.contains('secrétaire') || roleLower.contains('secretaire');
    final isTreasurer = roleLower.contains('trésorier') || roleLower.contains('tresorier');

    final List<Widget> cards;

    if (isSecretary) {
      cards = [
        TontiStatCard(
          title: 'RÉUNIONS DU MOIS',
          value: '${MockTontiData.meetings.length} Réunions',
          subtitle: 'Prochaine assemblée programmée',
          icon: Icons.event_available_outlined,
          iconColor: TontiColors.infoBlue,
          iconBgColor: TontiColors.infoSoft,
          onTap: widget.onNavigateToReunions,
        ),
        TontiStatCard(
          title: 'MEMBRES À RELANCER',
          value: '${MockTontiData.members.where((m) => m.status == MemberStatus.retard).length} Membres',
          subtitle: 'Signalement pour pénalités',
          icon: Icons.groups_outlined,
          iconColor: TontiColors.warningOrange,
          iconBgColor: TontiColors.warningSoft,
          onTap: widget.onNavigateToReunions,
        ),
        TontiStatCard(
          title: 'ÉMARGEMENT & PRÉSENCES',
          value: '95% Présence',
          subtitle: 'Feuilles de présence archivées',
          icon: Icons.edit_note_outlined,
          iconColor: TontiColors.successGreen,
          iconBgColor: TontiColors.successSoft,
          onTap: widget.onNavigateToReunions,
        ),
        TontiStatCard(
          title: 'CONVOCATIONS WHATSAPP',
          value: 'Actives',
          subtitle: 'Rappels automatiques diffusés',
          icon: Icons.notifications_active_outlined,
          iconColor: TontiColors.primaryGold,
          iconBgColor: TontiColors.goldSoft,
          onTap: widget.onNavigateToReunions,
        ),
      ];
    } else if (isTreasurer) {
      final pendingCount = MockTontiData.transactions.where((t) => t.status == TransactionStatus.aVerifier).length;
      cards = [
        TontiStatCard(
          title: 'COTISATIONS À VALIDER',
          value: '$pendingCount en attente',
          subtitle: 'Total : ${Formatters.formatFCFA(caisse.pendingValidationAmount)}',
          icon: Icons.fact_check_outlined,
          iconColor: TontiColors.warningOrange,
          iconBgColor: TontiColors.warningSoft,
          onTap: widget.onNavigateToCotisations,
        ),
        TontiStatCard(
          title: 'SOLDE DISPONIBLE CAISSE',
          value: Formatters.formatFCFA(caisse.totalActualAvailable),
          subtitle: '${Formatters.formatFCFA(caisse.mobileMoneyBalance)} MoMo • ${Formatters.formatFCFA(caisse.availableCashBalance)} Cash',
          icon: Icons.account_balance_wallet_outlined,
          iconColor: TontiColors.successGreen,
          iconBgColor: TontiColors.successSoft,
          onTap: widget.onNavigateToCaisse,
        ),
        TontiStatCard(
          title: 'PROCHAINE DISTRIBUTION',
          value: nextDist == null ? '—' : Formatters.formatFCFA(nextDist.netAmount),
          subtitle: nextDist == null ? 'Aucune cagnotte' : 'Bénéficiaire : ${nextDist.beneficiaryName}',
          icon: Icons.sync_alt_outlined,
          iconColor: TontiColors.primaryGold,
          iconBgColor: TontiColors.goldSoft,
          onTap: widget.onNavigateToCaisse,
        ),
        TontiStatCard(
          title: 'ENTRÉES DU MOIS',
          value: Formatters.formatFCFA(caisse.totalIncome),
          subtitle: 'Rapprochement comptable à jour',
          icon: Icons.payments_outlined,
          iconColor: TontiColors.infoBlue,
          iconBgColor: TontiColors.infoSoft,
          onTap: widget.onNavigateToCaisse,
        ),
      ];
    } else if (!isPresident) {
      // Membre Simple
      final currentUser = AuthController().currentUser;
      final myMember = MockTontiData.members.firstWhere(
        (m) => m.fullName.toLowerCase().contains(currentUser?.fullName.toLowerCase() ?? ''),
        orElse: () => MockTontiData.members.first,
      );
      cards = [
        TontiStatCard(
          title: 'MA SITUATION COTISATION',
          value: Formatters.formatFCFA(myMember.totalContributed > 0 ? myMember.totalContributed : 100000),
          subtitle: 'Scolarité & Tontine de famille',
          icon: Icons.payments_outlined,
          iconColor: TontiColors.successGreen,
          iconBgColor: TontiColors.successSoft,
          onTap: widget.onRecordPaymentRequested,
        ),
        TontiStatCard(
          title: 'MON ATTENDU CE CYCLE',
          value: Formatters.formatFCFA(myMember.totalExpected > 0 ? myMember.totalExpected : 100000),
          subtitle: 'Cotisation mensuelle individuelle',
          icon: Icons.account_balance_wallet_outlined,
          iconColor: TontiColors.primaryGold,
          iconBgColor: TontiColors.goldSoft,
          onTap: widget.onRecordPaymentRequested,
        ),
        TontiStatCard(
          title: 'MON STATUT',
          value: 'Actif',
          subtitle: 'Position validée dans la tontine',
          icon: Icons.stars_outlined,
          iconColor: TontiColors.infoBlue,
          iconBgColor: TontiColors.infoSoft,
        ),
        TontiStatCard(
          title: 'PROCHAINE ÉCHÉANCE',
          value: daysLeft == null ? '15 du mois' : (daysLeft <= 0 ? 'Aujourd\'hui' : 'Dans $daysLeft jours'),
          subtitle: 'Prochaine réunion & versement',
          icon: Icons.event_available_outlined,
          iconColor: TontiColors.warningOrange,
          iconBgColor: TontiColors.warningSoft,
          onTap: widget.onNavigateToReunions,
        ),
      ];
    } else {
      // Président
      cards = [
        TontiStatCard(
          title: 'COTISATIONS CE MOIS',
          value: Formatters.formatFCFA(collectedMonth),
          subtitle: 'Attendu : ${Formatters.formatFCFA(_expectedPerMonth)}',
          icon: Icons.payments_outlined,
          iconColor: TontiColors.primaryGold,
          iconBgColor: TontiColors.goldSoft,
          onTap: widget.onNavigateToCotisations,
        ),
        TontiStatCard(
          title: 'FONDS DISPONIBLES EN CAISSE',
          value: Formatters.formatFCFA(MockTontiData.caisseSummary.totalActualAvailable),
          subtitle: 'Dont ${Formatters.formatFCFA(caisse.mobileMoneyBalance)} MoMo & ${Formatters.formatFCFA(caisse.availableCashBalance)} Cash',
          icon: Icons.account_balance_wallet_outlined,
          iconColor: TontiColors.successGreen,
          iconBgColor: TontiColors.successSoft,
          onTap: widget.onNavigateToCaisse,
        ),
        TontiStatCard(
          title: 'TONTINES ACTIVES',
          value: '${MockTontiData.tontines.where((t) => t.status == TontineStatus.active).length} Groupes',
          subtitle: '$totalMembers membres au total',
          icon: Icons.groups_outlined,
          iconColor: TontiColors.infoBlue,
          iconBgColor: TontiColors.infoSoft,
          onTap: widget.onNavigateToTontines,
        ),
        TontiStatCard(
          title: 'PROCHAINE ÉCHÉANCE',
          value: daysLeft == null ? '—' : (daysLeft <= 0 ? 'Aujourd\'hui' : 'Dans $daysLeft jours'),
          subtitle: nextDist == null ? 'Aucune distribution prévue' : nextDist.beneficiaryName,
          icon: Icons.event_available_outlined,
          iconColor: TontiColors.warningOrange,
          iconBgColor: TontiColors.warningSoft,
          trendLabel: nextDist == null ? null : Formatters.formatFCFA(nextDist.netAmount),
        ),
      ];
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          return Row(
            children: cards.map((card) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: card,
              ),
            )).toList(),
          );
        } else if (constraints.maxWidth >= 600) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: cards,
          );
        } else {
          return Column(
            children: cards.map((card) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: card,
            )).toList(),
          );
        }
      },
    );
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

  void _showTransactionDetailsModal(BuildContext context, TransactionModel txn) {
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
    final dist = _nextDistribution;
    if (dist == null) return;
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
                Text(
                  'Vous préparez le déblocage pour ${dist.beneficiaryName}.',
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
                      Text(Formatters.formatFCFA(dist.theoreticalAmount), style: TontiTypography.amountSmall),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  dist.beneficiaryPhone.isEmpty ? 'Téléphone du bénéficiaire non renseigné' : 'Contact du bénéficiaire : ${dist.beneficiaryPhone}',
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
              onPressed: () async {
                final user = AuthController().currentUser;
                Navigator.pop(ctx);
                final ok = user != null &&
                    await LocalTontiDataSource()
                        .signDistribution(distributionId: dist.id, performedByUser: user);
                if (!context.mounted) return;
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'Signature enregistrée par le serveur.'
                        : 'Le serveur a refusé la signature (rôle ou données manquantes).'),
                    backgroundColor: ok ? TontiColors.successGreen : TontiColors.alertRed,
                  ),
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

/// Carte d'accès rapide : pastille d'icône, flèche, titre et description.
class _QuickAccessCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<_QuickAccessCard> createState() => _QuickAccessCardState();
}

class _QuickAccessCardState extends State<_QuickAccessCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: TontiColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hover ? TontiColors.primaryGold : TontiColors.border,
              width: _hover ? 1.4 : 1,
            ),
            boxShadow: _hover ? [TontiColors.elevatedShadow] : [TontiColors.softShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: TontiColors.goldSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(widget.icon, color: TontiColors.primaryGold, size: 24),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded, size: 20, color: _hover ? TontiColors.primaryGold : TontiColors.textMuted),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                widget.title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: TontiColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                widget.description,
                style: const TextStyle(fontSize: 13.5, height: 1.5, color: TontiColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
