import 'governance_screen.dart';
import 'bureau_screen.dart';
import 'widgets/invitations_panel.dart';
import '../../widgets/common/invite_member_dialog.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/mock_tonti_data.dart';
import '../../../models/tontine_model.dart';
import '../../../models/member_model.dart';
import '../../../models/transaction_model.dart';
import '../../../models/distribution_model.dart';
import '../../widgets/common/tonti_card.dart';
import '../../widgets/common/tonti_button.dart';
import '../../widgets/common/tonti_badge.dart';
import '../../../data/repositories/tontine_repository_impl.dart';
import '../../../data/datasources/local_tonti_datasource.dart';
import '../../../domain/entities/turn_entity.dart';
import '../../../core/network/api_client.dart';

class TontineDetailScreen extends StatefulWidget {
  final TontineModel tontine;
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
                        label: 'Vie de la tontine',
                        icon: Icons.forum_outlined,
                        type: TontiButtonType.outline,
                        height: 38,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => GovernanceScreen(tontine: widget.tontine)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TontiButton(
                        label: 'Gestion avancée',
                        icon: Icons.tune,
                        type: TontiButtonType.outline,
                        height: 38,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => BureauScreen(tontine: widget.tontine)),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                    Tab(icon: Icon(Icons.sync_alt), text: 'Ordre de passage'),
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
              Text('État de la collecte du cycle en cours', style: TontiTypography.headingMedium),
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
    final tontineMembers = widget.tontine.members;
    return ListView.builder(
      itemCount: tontineMembers.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return InvitationsPanel(
            tontineNumericId: int.tryParse(
              widget.tontine.id.replaceAll(RegExp(r'[^0-9]'), ''),
            ),
            canInvite: widget.activeRole == 'Président',
            onChanged: () => setState(() {}),
          );
        }
        final mem = tontineMembers[index - 1];
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
                    if (!mem.canContribute) ...[
                      const SizedBox(height: 4),
                      TontiBadge(
                        label: 'Cotisation bloquée • ${mem.unpaidPenaltiesCount} pénalité(s)',
                        variant: BadgeVariant.danger,
                        isSmall: true,
                      ),
                    ],
                  ],
                ),
                if (widget.activeRole == 'Président' && mem.role != MemberRole.president) ...[
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.manage_accounts, color: TontiColors.darkGold, size: 22),
                    tooltip: 'Attribuer un rôle statutaire (Président)',
                    onPressed: () => _showAssignRoleModal(context, mem),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAssignRoleModal(BuildContext context, MemberModel member) {
    MemberRole selectedRole = member.role;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: TontiColors.primaryGold),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Gérer les droits : ${member.fullName}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Règle statutaire : Seul le Président a la prérogative d\'assigner ou de modifier les rôles au sein du bureau exécutif.',
                style: TextStyle(fontSize: 12, color: TontiColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const Text('Sélectionner le rôle statutaire :', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              RadioListTile<MemberRole>(
                value: MemberRole.tresorier,
                groupValue: selectedRole,
                title: const Text('Trésorier'),
                subtitle: const Text('Gestion des fonds, encaissements, 2nde signature'),
                onChanged: (val) => setModalState(() => selectedRole = val!),
              ),
              RadioListTile<MemberRole>(
                value: MemberRole.secretaire,
                groupValue: selectedRole,
                title: const Text('Secrétaire'),
                subtitle: const Text('Comptes-rendus, présences & convocations'),
                onChanged: (val) => setModalState(() => selectedRole = val!),
              ),
              RadioListTile<MemberRole>(
                value: MemberRole.commissaire,
                groupValue: selectedRole,
                title: const Text('Commissaire aux comptes'),
                subtitle: const Text('Contrôle de conformité et audit de caisse'),
                onChanged: (val) => setModalState(() => selectedRole = val!),
              ),
              RadioListTile<MemberRole>(
                value: MemberRole.membre,
                groupValue: selectedRole,
                title: const Text('Membre Simple'),
                subtitle: const Text('Cotisant actif régulier'),
                onChanged: (val) => setModalState(() => selectedRole = val!),
              ),
            ],
          ),
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: TontiColors.primaryGold),
              onPressed: () async {
                final repo = TontineRepositoryImpl();
                final currentUser = LocalTontiDataSource().currentUser;
                final updated = await repo.updateMemberRole(
                  tontineId: widget.tontine.id,
                  memberId: member.id,
                  newRole: selectedRole,
                  performedByUser: currentUser,
                  reason: 'Nomination statutaire par le Président',
                );
                if (!context.mounted) return;
                if (!updated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Le serveur a refusé la modification du rôle. Vérifiez vos droits et la connexion.',
                      ),
                      backgroundColor: TontiColors.alertRed,
                    ),
                  );
                  return;
                }
                setState(() {});
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rôle mis à jour pour ${member.fullName} avec succès !'),
                    backgroundColor: TontiColors.successGreen,
                  ),
                );
              },
              child: const Text('Confirmer l\'attribution', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Onglet 3 : Historique Cotisations
  Widget _buildCotisationsTab(bool isDesktop) {
    final cotisations = MockTontiData.transactions
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

  void _snack(ApiResponse r, String okMsg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(r.isOk ? (r.message ?? okMsg) : (r.message ?? 'Refusé par le serveur.')),
      backgroundColor: r.isOk ? TontiColors.successGreen : TontiColors.alertRed,
    ));
    if (r.isOk) setState(() {});
  }

  Future<void> _swapTurn(int cycleId, TurnEntity source, List<TurnEntity> all) async {
    int? target;
    final others = all.where((t) => t.rank != source.rank).toList();
    final chosen = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Permuter le tour'),
          content: DropdownButtonFormField<int>(
            value: target,
            hint: const Text('Permuter avec…'),
            items: others
                .map((t) => DropdownMenuItem(value: t.rank, child: Text(t.memberName)))
                .toList(),
            onChanged: (v) => setLocal(() => target = v),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: target == null ? null : () => Navigator.pop(ctx, target),
              child: const Text('Permuter'),
            ),
          ],
        ),
      ),
    );
    if (chosen == null) return;
    final r = await LocalTontiDataSource().swapTurns(cycleId, rankSource: source.rank, rankTarget: chosen);
    _snack(r, 'Tours permutés.');
  }

  Future<void> _regenerateTurns(int cycleId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tirage au sort'),
        content: const Text('Régénérer l\'ordre de passage du cycle par tirage au sort ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Tirer au sort')),
        ],
      ),
    );
    if (ok != true) return;
    final r = await LocalTontiDataSource().regenerateTurnOrder(cycleId, methode: 'TIRAGE_SORT');
    _snack(r, 'Ordre de passage régénéré.');
  }

  String _fmtDate(DateTime? d) =>
      d == null ? '—' : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // Onglet 4 : Ordre de passage (tours du cycle en cours, contrat §1.9)
  Widget _buildDistributionsTab(bool isDesktop) {
    final ds = LocalTontiDataSource();
    final tid = LocalTontiDataSource.numericId(widget.tontine.id);
    final cycleId = ds.cycleIdFor(tid);
    final turns = ds.turnsFor(tid);
    final canManage = cycleId != null && (ds.currentUser.isPresident || ds.currentUser.isTreasurer);
    if (turns.isEmpty) {
      return const Center(child: Text('Aucun tour planifié pour le cycle en cours.'));
    }
    return ListView(
      children: [
        if (canManage)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => _regenerateTurns(cycleId!),
                icon: const Icon(Icons.shuffle, size: 16),
                label: const Text('Tirage au sort'),
              ),
            ),
          ),
        for (final turn in turns)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TontiCard(
              padding: const EdgeInsets.all(16),
              hasGoldBorder: turn.status == TurnStatus.preteADistribuer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(turn.memberName,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            TontiBadge(
                              label: turn.statusLabel,
                              variant: turn.status == TurnStatus.confirmee || turn.status == TurnStatus.effectuee
                                  ? BadgeVariant.success
                                  : turn.status == TurnStatus.preteADistribuer
                                      ? BadgeVariant.gold
                                      : BadgeVariant.neutral,
                              isSmall: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Date prévue : ${_fmtDate(turn.plannedDate)} • Collecté : '
                          '${Formatters.formatFCFA(turn.collectedAmount)} / ${Formatters.formatFCFA(turn.plannedAmount)}',
                          style: TontiTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    Formatters.formatFCFA(turn.plannedAmount),
                    style: TontiTypography.amountMedium.copyWith(color: TontiColors.primaryGold),
                  ),
                  if (canManage && !turn.isFinished)
                    IconButton(
                      icon: const Icon(Icons.swap_vert, color: TontiColors.darkGold),
                      tooltip: 'Permuter ce tour',
                      onPressed: () => _swapTurn(cycleId!, turn, turns),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showInviteMemberModal(BuildContext context) {
    final numericId = LocalTontiDataSource.numericId(widget.tontine.id) ?? 1;
    InviteMemberDialog.show(context, tontineId: numericId, onInviteSuccess: () {
      setState(() {});
    });
  }
}
