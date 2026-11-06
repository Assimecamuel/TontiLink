import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/datasources/local_tonti_datasource.dart';
import '../../../data/mock_tonti_data.dart';
import '../../../models/member_model.dart';
import '../../../models/transaction_model.dart';
import '../../widgets/common/tonti_card.dart';
import '../../widgets/common/tonti_button.dart';
import '../../widgets/common/tonti_badge.dart';

class CotisationsScreen extends StatefulWidget {
  final VoidCallback onRecordPayment;
  final String activeRole;

  const CotisationsScreen({
    super.key,
    required this.onRecordPayment,
    this.activeRole = 'Président',
  });

  @override
  State<CotisationsScreen> createState() => _CotisationsScreenState();
}

class _CotisationsScreenState extends State<CotisationsScreen> {
  String selectedFilter = 'Tous';

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    final confirmed = MockTontiData.transactions.where((t) =>
        t.type == TransactionType.cotisation && t.status == TransactionStatus.confirme);
    final totalCollected = confirmed.fold<double>(0, (s, t) => s + t.amount);
    final totalExpected = MockTontiData.tontines.fold<double>(
        0, (s, t) => s + t.contributionAmount * t.memberCount);
    final percent = totalExpected > 0 ? (totalCollected / totalExpected * 100).round() : 0;
    final lateMembers =
        MockTontiData.members.where((m) => m.status == MemberStatus.retard).toList();
    final lateAmount = lateMembers.fold<double>(
        0, (s, m) => s + (m.totalExpected - m.totalContributed).clamp(0, double.infinity).toDouble());

    final filteredMembers = MockTontiData.members.where((m) {
      if (selectedFilter == 'À jour') return m.isUpToDate;
      if (selectedFilter == 'En retard') return !m.isUpToDate;
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
              // Entête
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cotisations & Échéances', style: TontiTypography.displayMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Suivi individuel des versements, gestion des retards et émission de reçus',
                        style: TontiTypography.bodySmall,
                      ),
                    ],
                  ),
                  TontiButton(
                    label: 'Enregistrer une cotisation',
                    icon: Icons.add,
                    onPressed: widget.onRecordPayment,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Résumé en 3 cartes adaptatif
              LayoutBuilder(
                builder: (context, constraints) {
                  final card1 = _buildSummaryCard(
                    'TOTAL COLLECTÉ CE CYCLE',
                    Formatters.formatFCFA(totalCollected),
                    '$percent% de l\'objectif réuni',
                    TontiColors.primaryGold,
                    Icons.savings_outlined,
                  );
                  final card2 = _buildSummaryCard(
                    'RETARDS DE COTISATION',
                    Formatters.formatFCFA(lateAmount),
                    '${lateMembers.length} membre(s) en retard',
                    TontiColors.alertRed,
                    Icons.warning_amber_rounded,
                  );
                  final card3 = _buildSummaryCard(
                    'VERSEMENTS EN ATTENTE',
                    Formatters.formatFCFA(MockTontiData.transactions.where((t) => t.status == TransactionStatus.aVerifier).fold<double>(0, (a, t) => a + t.amount)),
                    'En attente de validation par le bureau',
                    TontiColors.warningOrange,
                    Icons.handshake_outlined,
                  );

                  if (constraints.maxWidth >= 900) {
                    return Row(
                      children: [
                        Expanded(child: card1),
                        const SizedBox(width: 14),
                        Expanded(child: card2),
                        const SizedBox(width: 14),
                        Expanded(child: card3),
                      ],
                    );
                  } else if (constraints.maxWidth >= 600) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: card1),
                            const SizedBox(width: 12),
                            Expanded(child: card2),
                          ],
                        ),
                        const SizedBox(height: 12),
                        card3,
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        card1,
                        const SizedBox(height: 12),
                        card2,
                        const SizedBox(height: 12),
                        card3,
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 24),

              _buildPendingValidations(context),

              // Filtres
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Situation des membres', style: TontiTypography.headingMedium),
                  Row(
                    children: [
                      _buildFilterChip('Tous'),
                      const SizedBox(width: 8),
                      _buildFilterChip('À jour'),
                      const SizedBox(width: 8),
                      _buildFilterChip('En retard'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tableau / Cartes des membres
              if (isDesktop)
                _buildDesktopTable(filteredMembers)
              else
                _buildMobileList(filteredMembers),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Cotisations déclarées, à valider par le bureau (POST .../valider/).
  Widget _buildPendingValidations(BuildContext context) {
    final user = LocalTontiDataSource().currentUser;
    final pending = MockTontiData.transactions
        .where((t) => t.type == TransactionType.cotisation && t.status == TransactionStatus.aVerifier)
        .toList();
    if (pending.isEmpty || !(user.isPresident || user.isTreasurer)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: TontiCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cotisations à valider', style: TontiTypography.headingMedium),
            const SizedBox(height: 8),
            ...pending.map((t) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('${t.memberName} • ${Formatters.formatFCFA(t.amount)}'),
                  subtitle: Text('${t.tontineName} • ${t.reference}'),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      final id = LocalTontiDataSource.numericId(t.id);
                      if (id == null) return;
                      final ok = await LocalTontiDataSource().validateCotisation(cotisationId: id);
                      if (!mounted) return;
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'Cotisation validée.' : 'Le serveur a refusé la validation (rôle insuffisant ?).'),
                          backgroundColor: ok ? TontiColors.successGreen : TontiColors.alertRed,
                        ),
                      );
                    },
                    child: const Text('Valider'),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String sub, Color color, IconData icon) {
    return TontiCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: TontiColors.textSecondary)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: TontiTypography.amountMedium.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(sub, style: TontiTypography.bodySmall),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => selectedFilter = label);
      },
      selectedColor: TontiColors.goldSoft,
      backgroundColor: TontiColors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? TontiColors.darkGold : TontiColors.textSecondary,
      ),
      side: BorderSide(color: isSelected ? TontiColors.primaryGold : TontiColors.border),
    );
  }

  void _showReportLateMemberDialog(BuildContext context, MemberModel member) async {
    final ds = LocalTontiDataSource();
    final numericTid = ds.activeTontineId ?? 1;
    final numericAdh = LocalTontiDataSource.numericId(member.id) ?? 1;

    double recommendedAmount = 2500;
    bool aDejaBouffe = false;

    final calcRes = await ds.calculatePenalty(
      tontineId: numericTid,
      adhesionId: numericAdh,
      montant: 2500,
    );

    if (calcRes.isOk && calcRes.data is Map) {
      final data = calcRes.data as Map;
      recommendedAmount = (data['montant_recommande'] as num?)?.toDouble() ?? 2500;
      aDejaBouffe = data['a_deja_bouffe'] == true;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TontiColors.alertSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add_alert_rounded, color: TontiColors.alertRed),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Signaler retard de cotisation', style: TextStyle(fontSize: 18))),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Membre concerné : ${member.fullName} (${member.phone})',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  'Retard enregistré : ${Formatters.formatFCFA(member.totalExpected - member.totalContributed)}',
                  style: const TextStyle(color: TontiColors.alertRed, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: aDejaBouffe ? const Color(0xFFFEF2F2) : TontiColors.goldSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: aDejaBouffe ? TontiColors.alertRed : TontiColors.primaryGold,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            aDejaBouffe ? Icons.warning_rounded : Icons.info_outline_rounded,
                            color: aDejaBouffe ? TontiColors.alertRed : TontiColors.darkGold,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              aDejaBouffe
                                  ? 'PÉNALITÉ AGGRAVÉE (A DÉJÀ BÉNÉFICIÉ DU TOUR)'
                                  : 'PÉNALITÉ STANDARD (N\'A PAS ENCORE BÉNÉFICIÉ)',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 11.5,
                                color: aDejaBouffe ? TontiColors.alertRed : TontiColors.darkGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        aDejaBouffe
                            ? 'Ce membre a déjà perçu la cagnotte du cycle. En tant que débiteur strict, sa pénalité recommandée est doublée (x2) : ${Formatters.formatFCFA(recommendedAmount)}.'
                            : 'Ce membre n\'a pas encore perçu la cagnotte. Pénalité statutaire recommandée : ${Formatters.formatFCFA(recommendedAmount)}.',
                        style: const TextStyle(fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Text('Actions transmises simultanément :', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: TontiColors.successGreen),
                    SizedBox(width: 8),
                    Expanded(child: Text('Notification & rapport d\'impayé transmis au Secrétaire.', style: TextStyle(fontSize: 12))),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF25D366)),
                    SizedBox(width: 8),
                    Expanded(child: Text('Rappel WhatsApp ferme envoyé au membre (+237697951571).', style: TextStyle(fontSize: 12))),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.sms_outlined, size: 16, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Expanded(child: Text('Rappel SMS ferme expédié directement au numéro du membre.', style: TextStyle(fontSize: 12))),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: TontiColors.alertRed),
            onPressed: () async {
              Navigator.pop(ctx);

              await ds.applyPenalty(
                tontineId: numericTid,
                adhesionId: numericAdh,
                montant: recommendedAmount,
                motif: aDejaBouffe
                    ? '[PÉNALITÉ AGGRAVÉE - A DÉJÀ BÉNÉFICIÉ DU TOUR DE CAGNOTTE] Retard de versement'
                    : '[PÉNALITÉ STANDARD] Retard de versement',
              );

              final cleanPhone = member.phone.replaceAll(RegExp(r'\s+'), '');
              final targetPhone = cleanPhone.startsWith('+') ? cleanPhone : '+237$cleanPhone';
              final msgText =
                'RAPPEL TONTILINK : Bonjour ${member.fullName}, votre cotisation de ${Formatters.formatFCFA(member.totalExpected - member.totalContributed)} est en retard. '
                '${aDejaBouffe ? "Avertissement : Ayant déjà bénéficié de la cagnotte, une pénalité majorée x2 de " + Formatters.formatFCFA(recommendedAmount) + " s'applique." : "Une pénalité de " + Formatters.formatFCFA(recommendedAmount) + " a été signalée au Secrétaire."} Merci de régulariser rapidement.';
              final encodedMsg = Uri.encodeComponent(msgText);

              // 1. WhatsApp
              final waUrl = Uri.parse('https://wa.me/$targetPhone?text=$encodedMsg');
              if (await canLaunchUrl(waUrl)) {
                await launchUrl(waUrl, mode: LaunchMode.externalApplication);
              }

              // 2. SMS Direct
              final smsUrl = Uri.parse('sms:$targetPhone?body=$encodedMsg');
              if (await canLaunchUrl(smsUrl)) {
                await launchUrl(smsUrl, mode: LaunchMode.externalApplication);
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Retard de ${member.fullName} signalé au Secrétaire et rappel WhatsApp & SMS transmis !',
                    ),
                    backgroundColor: TontiColors.successGreen,
                  ),
                );
              }
            },
            icon: const Icon(Icons.add_alert_rounded, size: 18),
            label: const Text('Signaler & Notifier'),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(List<MemberModel> members) {
    return Container(
      decoration: BoxDecoration(
        color: TontiColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TontiColors.border),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2.0),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(1.2),
          5: FixedColumnWidth(180),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          const TableRow(
            decoration: BoxDecoration(
              color: TontiColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            children: [
              Padding(padding: EdgeInsets.all(14), child: Text('MEMBRE & CONTACT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: TontiColors.textMuted))),
              Padding(padding: EdgeInsets.all(14), child: Text('RÔLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: TontiColors.textMuted))),
              Padding(padding: EdgeInsets.all(14), child: Text('COTISATION VERSÉE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: TontiColors.textMuted))),
              Padding(padding: EdgeInsets.all(14), child: Text('ATTENDU CYCLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: TontiColors.textMuted))),
              Padding(padding: EdgeInsets.all(14), child: Text('STATUT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: TontiColors.textMuted))),
              Padding(padding: EdgeInsets.all(14), child: Text('ACTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: TontiColors.textMuted))),
            ],
          ),
          ...members.map((mem) {
            return TableRow(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: TontiColors.divider)),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: TontiColors.goldSoft,
                        child: Text(mem.avatarInitials, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: TontiColors.darkGold)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mem.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                          Text(Formatters.formatCameroonPhone(mem.phone), style: TontiTypography.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(mem.roleLabel, style: const TextStyle(fontSize: 12.5)),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(Formatters.formatFCFA(mem.totalContributed), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(Formatters.formatFCFA(mem.totalExpected), style: const TextStyle(fontSize: 13, color: TontiColors.textSecondary)),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: TontiBadge(
                    label: mem.isUpToDate ? 'À jour' : 'En retard',
                    variant: mem.isUpToDate ? BadgeVariant.success : BadgeVariant.danger,
                    isSmall: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: (widget.activeRole == 'Trésorier' || widget.activeRole == 'Président')
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton(
                              onPressed: mem.canContribute ? widget.onRecordPayment : null,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                              ),
                              child: Text(mem.canContribute ? 'Encaisser' : 'Bloqué', style: const TextStyle(fontSize: 11.5)),
                            ),
                            if (!mem.isUpToDate) ...[
                              const SizedBox(width: 6),
                              IconButton(
                                icon: const Icon(Icons.add_alert_rounded, color: TontiColors.alertRed, size: 20),
                                tooltip: 'Signaler retard (Secrétaire & Membre)',
                                onPressed: () => _showReportLateMemberDialog(context, mem),
                              ),
                            ],
                          ],
                        )
                      : Text(
                          mem.isUpToDate ? 'En règle' : 'En attente',
                          style: const TextStyle(fontSize: 12, color: TontiColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<MemberModel> members) {
    return Column(
      children: members.map((mem) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TontiCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: TontiColors.goldSoft,
                  child: Text(mem.avatarInitials, style: const TextStyle(color: TontiColors.darkGold, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mem.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                      const SizedBox(height: 2),
                      Text('Versé : ${Formatters.formatFCFA(mem.totalContributed)}', style: TontiTypography.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TontiBadge(
                      label: mem.isUpToDate ? 'À jour' : 'En retard',
                      variant: mem.isUpToDate ? BadgeVariant.success : BadgeVariant.danger,
                      isSmall: true,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: mem.canContribute ? widget.onRecordPayment : null,
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                          child: Text(
                            mem.canContribute ? 'Encaisser' : 'Bloqué',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: mem.canContribute ? TontiColors.primaryGold : TontiColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!mem.isUpToDate && (widget.activeRole == 'Trésorier' || widget.activeRole == 'Président')) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _showReportLateMemberDialog(context, mem),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Icons.add_alert_rounded, color: TontiColors.alertRed, size: 18),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

