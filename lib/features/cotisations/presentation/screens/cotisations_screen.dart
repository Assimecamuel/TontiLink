import 'package:flutter/material.dart';
import '../../../../core/theme/tonti_colors.dart';
import '../../../../core/theme/tonti_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../injection_container.dart';
import '../../../members/domain/entities/member.dart';
import '../../../../shared/widgets/common/tonti_card.dart';
import '../../../../shared/widgets/common/tonti_button.dart';
import '../../../../shared/widgets/common/tonti_badge.dart';

class CotisationsScreen extends StatefulWidget {
  final VoidCallback onRecordPayment;

  const CotisationsScreen({
    super.key,
    required this.onRecordPayment,
  });

  @override
  State<CotisationsScreen> createState() => _CotisationsScreenState();
}

class _CotisationsScreenState extends State<CotisationsScreen> {
  String selectedFilter = 'Tous';

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    final filteredMembers = sl.membersController.members.where((m) {
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

              // Résumé en 3 cartes
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'TOTAL COLLECTÉ CE CYCLE',
                      Formatters.formatFCFA(4250000),
                      '92% de l\'objectif réuni',
                      TontiColors.primaryGold,
                      Icons.savings_outlined,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildSummaryCard(
                      'RETARDS DE COTISATION',
                      Formatters.formatFCFA(250000),
                      '1 membre en retard (2 cycles)',
                      TontiColors.alertRed,
                      Icons.warning_amber_rounded,
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildSummaryCard(
                        'VERSEMENTS ESPÈCES EN ATTENTE',
                        Formatters.formatFCFA(sl.caisseController.caisseSummary.pendingValidationAmount),
                        'À rapprocher par le trésorier',
                        TontiColors.warningOrange,
                        Icons.handshake_outlined,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Filtres
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Situation des membres (Tour #7)', style: TontiTypography.headingMedium),
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

  Widget _buildDesktopTable(List<Member> members) {
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
          5: FixedColumnWidth(110),
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
                  child: OutlinedButton(
                    onPressed: widget.onRecordPayment,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Encaisser', style: TextStyle(fontSize: 11.5)),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<Member> members) {
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
                    TextButton(
                      onPressed: widget.onRecordPayment,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                      child: const Text('Encaisser', style: TextStyle(fontSize: 11.5, color: TontiColors.primaryGold, fontWeight: FontWeight.w700)),
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

