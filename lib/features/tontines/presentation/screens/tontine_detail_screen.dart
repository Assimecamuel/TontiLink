import 'package:flutter/material.dart';
import '../../../../presentation/widgets/common/invite_member_dialog.dart';
import '../../../../core/theme/tonti_colors.dart';
import '../../../../core/theme/tonti_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/tontine.dart';
import '../../../members/domain/entities/member.dart';
import '../../../cotisations/domain/entities/transaction.dart';
import '../../../distributions/domain/entities/distribution.dart';
import '../../../../shared/widgets/common/tonti_card.dart';
import '../../../../shared/widgets/common/tonti_button.dart';
import '../../../../shared/widgets/common/tonti_badge.dart';

class TontineDetailScreen extends StatefulWidget {
  final Tontine tontine;
  final VoidCallback onBack;
  final VoidCallback onRecordPayment;
  final String activeRole;

  const TontineDetailScreen({
    super.key,
    required this.tontine,
    required this.onBack,
    required this.onRecordPayment,
    required this.activeRole,
  });

  @override
  State<TontineDetailScreen> createState() => _TontineDetailScreenState();
}

class _TontineDetailScreenState extends State<TontineDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
              // Bouton retour & actions supérieures
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back, color: TontiColors.textPrimary),
                    label: const Text(
                      'Retour à la liste des tontines',
                      style: TextStyle(color: TontiColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    children: [
                      TontiButton(
                        label: 'Inviter un membre',
                        icon: Icons.person_add_alt_1,
                        type: TontiButtonType.outline,
                        height: 38,
                        onPressed: () => _showInviteMemberModal(context),
                      ),
                      const SizedBox(width: 10),
                      TontiButton(
                        label: 'Cotiser maintenant',
                        icon: Icons.payments_outlined,
                        height: 38,
                        onPressed: widget.onRecordPayment,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Carte En-tête de la tontine
              _buildTontineHeaderCard(context, isDesktop),
              const SizedBox(height: 24),

              // Barre d'onglets
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: TontiColors.border, width: 1)),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: !isDesktop,
                  labelColor: TontiColors.primaryGold,
                  unselectedLabelColor: TontiColors.textSecondary,
                  indicatorColor: TontiColors.primaryGold,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  tabs: const [
                    Tab(icon: Icon(Icons.dashboard_outlined), text: 'Vue d\'ensemble'),
                    Tab(icon: Icon(Icons.people_outline), text: 'Membres & Rôles'),
                    Tab(icon: Icon(Icons.history), text: 'Historique des Cotisations'),
                    Tab(icon: Icon(Icons.sync_alt), text: 'Calendrier des Distributions'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Contenu de l'onglet actif
              SizedBox(
                height: 600,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(isDesktop),
                    _buildMembersTab(isDesktop),
                    _buildCotisationsTab(isDesktop),
                    _buildDistributionsTab(isDesktop),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTontineHeaderCard(BuildContext context, bool isDesktop) {
    return TontiCard(
      padding: const EdgeInsets.all(24),
      hasGoldBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [TontiColors.primaryGold, TontiColors.darkGold],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.account_balance, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(widget.tontine.name, style: TontiTypography.headingLarge),
                          const SizedBox(width: 10),
                          TontiBadge(label: widget.tontine.typeLabel, variant: BadgeVariant.gold),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(widget.tontine.description, style: TontiTypography.bodySmall),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Montant cagnotte par tour', style: TextStyle(fontSize: 11, color: TontiColors.textSecondary)),
                  Text(
                    Formatters.formatFCFA(widget.tontine.totalCycleAmount),
                    style: TontiTypography.amountLarge.copyWith(color: TontiColors.primaryGold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          // Indicateurs rapides
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderStat('Cotisation par membre', Formatters.formatFCFA(widget.tontine.contributionAmount)),
              _buildHeaderStat('Fréquence', widget.tontine.frequencyLabel),
              _buildHeaderStat('Membres', '${widget.tontine.memberCount} membres'),
              _buildHeaderStat('Prochaine levée', 'Dans ${widget.tontine.nextDueDate.difference(DateTime.now()).inDays} jours'),
              _buildHeaderStat('Bénéficiaire en cours', widget.tontine.nextBeneficiaryName),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: TontiColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: TontiColors.textPrimary)),
      ],
    );
  }

  // Onglet 1 : Vue d'ensemble
  Widget _buildOverviewTab(bool isDesktop) {
    return ListView(
      children: [
        TontiCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Règlement & Fonctionnement approuvé', style: TontiTypography.headingMedium),
              const SizedBox(height: 10),
              const Text(
                '1. Tout versement de cotisation doit être effectué au plus tard 48h avant la séance de distribution.\n'
                '2. Tout retard non justifié engendre une pénalité forfaitaire de 5 000 FCFA conformément à l\'article 12.\n'
                '3. Le déblocage des fonds de la cagnotte requiert obligatoirement la double signature du Trésorier et du Président.\n'
                '4. Les paiements en espèces sont reçus uniquement lors des séances physiques et font l\'objet d\'un reçu instantané.',
                style: TextStyle(fontSize: 13, height: 1.6, color: TontiColors.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TontiCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('État de la collecte du cycle en cours (Tour #${widget.tontine.currentCycle})', style: TontiTypography.headingMedium),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Encaissé : ${Formatters.formatFCFA(widget.tontine.collectedAmountThisPeriod)} / ${Formatters.formatFCFA(widget.tontine.totalCycleAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${((widget.tontine.collectedAmountThisPeriod / widget.tontine.totalCycleAmount) * 100).toInt()}% réuni',
                    style: const TextStyle(color: TontiColors.primaryGold, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: widget.tontine.collectedAmountThisPeriod / widget.tontine.totalCycleAmount,
                  minHeight: 10,
                  backgroundColor: TontiColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(TontiColors.primaryGold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Onglet 2 : Membres & Rôles
  Widget _buildMembersTab(bool isDesktop) {
    return ListView.builder(
      itemCount: sl.membersController.members.length,
      itemBuilder: (context, index) {
        final mem = sl.membersController.members[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TontiCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: TontiColors.goldSoft,
                  child: Text(
                    mem.avatarInitials,
                    style: const TextStyle(color: TontiColors.darkGold, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(mem.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(width: 8),
                          TontiBadge(
                            label: mem.roleLabel,
                            variant: mem.role == MemberRole.president || mem.role == MemberRole.tresorier
                                ? BadgeVariant.gold
                                : BadgeVariant.neutral,
                            isSmall: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(Formatters.formatCameroonPhone(mem.phone), style: TontiTypography.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total cotisé : ${Formatters.formatFCFA(mem.totalContributed)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    TontiBadge(
                      label: mem.isUpToDate ? 'À jour' : 'En retard (${mem.latePaymentsCount})',
                      variant: mem.isUpToDate ? BadgeVariant.success : BadgeVariant.danger,
                      isSmall: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Onglet 3 : Historique Cotisations
  Widget _buildCotisationsTab(bool isDesktop) {
    final cotisations = sl.cotisationsController.transactions
        .where((t) => t.type == TransactionType.cotisation)
        .toList();

    return ListView.builder(
      itemCount: cotisations.length,
      itemBuilder: (context, index) {
        final item = cotisations[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TontiCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.memberName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('${item.paymentMethodLabel} • ${item.reference}', style: TontiTypography.bodySmall),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(Formatters.formatFCFA(item.amount), style: TontiTypography.amountSmall),
                    const SizedBox(height: 4),
                    const TontiBadge(label: 'Encaissé', variant: BadgeVariant.success, isSmall: true),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Onglet 4 : Calendrier Distributions
  Widget _buildDistributionsTab(bool isDesktop) {
    return ListView.builder(
      itemCount: sl.distributionsController.distributions.length,
      itemBuilder: (context, index) {
        final dist = sl.distributionsController.distributions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TontiCard(
            padding: const EdgeInsets.all(16),
            hasGoldBorder: dist.status == DistributionStatus.enCollecte,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Tour #${dist.turnNumber} • ${dist.beneficiaryName}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(width: 8),
                        TontiBadge(
                          label: dist.statusLabel,
                          variant: dist.status == DistributionStatus.distribuee ? BadgeVariant.success : BadgeVariant.gold,
                          isSmall: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Date prévue : ${dist.scheduledDate.day}/${dist.scheduledDate.month}/${dist.scheduledDate.year}', style: TontiTypography.bodySmall),
                  ],
                ),
                Text(
                  Formatters.formatFCFA(dist.netAmount),
                  style: TontiTypography.amountMedium.copyWith(color: TontiColors.primaryGold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInviteMemberModal(BuildContext context) {
    InviteMemberDialog.show(context, tontineId: 1, onInviteSuccess: () {
      setState(() {});
    });
  }
}

