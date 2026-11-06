import 'package:flutter/material.dart';
import '../../../../core/theme/tonti_colors.dart';
import '../../../../core/theme/tonti_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/tontine.dart';
import '../../../../shared/widgets/common/tonti_card.dart';
import '../../../../shared/widgets/common/tonti_button.dart';
import '../../../../shared/widgets/common/tonti_badge.dart';

class TontinesScreen extends StatefulWidget {
  final ValueChanged<Tontine> onSelectTontine;
  final VoidCallback onCreateTontine;
  final VoidCallback onRecordPayment;

  const TontinesScreen({
    super.key,
    required this.onSelectTontine,
    required this.onCreateTontine,
    required this.onRecordPayment,
  });

  @override
  State<TontinesScreen> createState() => _TontinesScreenState();
}

class _TontinesScreenState extends State<TontinesScreen> {
  String selectedFilter = 'Toutes';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    // Filtrage dynamique
    final filteredList = sl.tontinesController.tontines.where((t) {
      if (searchQuery.isNotEmpty &&
          !t.name.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }
      if (selectedFilter == 'Rotatives') {
        return t.type == TontineType.rotative;
      } else if (selectedFilter == 'Cumulatives') {
        return t.type == TontineType.cumulative;
      } else if (selectedFilter == 'Avec Prêts') {
        return t.type == TontineType.avecPrets;
      } else if (selectedFilter == 'Entraide') {
        return t.type == TontineType.entraide;
      } else if (selectedFilter == 'Projets') {
        return t.type == TontineType.projetCollectif;
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
              // Entête avec bouton de création
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mes Tontines & Groupes', style: TontiTypography.displayMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Gérez vos cotisations, consultez les cycles et préparez les levées de fonds',
                        style: TontiTypography.bodySmall,
                      ),
                    ],
                  ),
                  TontiButton(
                    label: 'Créer une tontine',
                    icon: Icons.add,
                    onPressed: widget.onCreateTontine,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Barre de filtres et recherche
              _buildFilterAndSearchBar(context, isDesktop),
              const SizedBox(height: 24),

              // Grille ou liste de cartes de tontines
              if (filteredList.isEmpty)
                _buildEmptyState()
              else if (isDesktop)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return _buildTontineCard(filteredList[index]);
                  },
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildTontineCard(filteredList[index]),
                    );
                  },
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterAndSearchBar(BuildContext context, bool isDesktop) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: TontiColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: TontiColors.border),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher par nom de tontine ou ville...',
                    prefixIcon: Icon(Icons.search, color: TontiColors.textSecondary, size: 20),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Toutes'),
              const SizedBox(width: 8),
              _buildFilterChip('Rotatives'),
              const SizedBox(width: 8),
              _buildFilterChip('Cumulatives'),
              const SizedBox(width: 8),
              _buildFilterChip('Avec Prêts'),
              const SizedBox(width: 8),
              _buildFilterChip('Entraide'),
              const SizedBox(width: 8),
              _buildFilterChip('Projets'),
            ],
          ),
        ),
      ],
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
        fontSize: 12.5,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? TontiColors.darkGold : TontiColors.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? TontiColors.primaryGold : TontiColors.border,
      ),
    );
  }

  Widget _buildTontineCard(Tontine tontine) {
    return TontiCard(
      padding: const EdgeInsets.all(22),
      onTap: () => widget.onSelectTontine(tontine),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Haut de carte : Titre, Type, Tag
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TontiBadge(
                          label: tontine.coverTag,
                          variant: BadgeVariant.gold,
                          isSmall: true,
                        ),
                        const SizedBox(width: 6),
                        TontiBadge(
                          label: tontine.typeLabel,
                          variant: BadgeVariant.neutral,
                          isSmall: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tontine.name,
                      style: TontiTypography.headingMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tontine.description,
                      style: TontiTypography.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildStatusPill(tontine.status),
            ],
          ),

          const SizedBox(height: 16),

          // Indicateurs financiers clés
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: TontiColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: TontiColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cotisation / séance', style: TextStyle(fontSize: 11, color: TontiColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(Formatters.formatFCFA(tontine.contributionAmount), style: TontiTypography.amountSmall),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Cagnotte par cycle', style: TextStyle(fontSize: 11, color: TontiColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.formatFCFA(tontine.totalCycleAmount),
                      style: TontiTypography.amountSmall.copyWith(color: TontiColors.primaryGold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Membres actifs', style: TextStyle(fontSize: 11, color: TontiColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text('${tontine.memberCount} / ${tontine.maxMembers}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Barre d'avancement du cycle (ex: Tour 7/12)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cycle : Tour ${tontine.currentCycle} sur ${tontine.totalCycles}',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Prochain bénéficiaire : ${tontine.nextBeneficiaryName}',
                    style: const TextStyle(fontSize: 11.5, color: TontiColors.darkGold, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: tontine.progressRatio,
                  minHeight: 6,
                  backgroundColor: TontiColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(TontiColors.primaryGold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Boutons d'action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Échéance : dans ${tontine.nextDueDate.difference(DateTime.now()).inDays} jours',
                style: const TextStyle(fontSize: 12, color: TontiColors.textSecondary),
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => widget.onSelectTontine(tontine),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Voir détails', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: widget.onRecordPayment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Cotiser', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(TontineStatus status) {
    switch (status) {
      case TontineStatus.active:
        return const TontiBadge(label: 'Active', variant: BadgeVariant.success, isSmall: true);
      case TontineStatus.enPreparation:
        return const TontiBadge(label: 'En préparation', variant: BadgeVariant.warning, isSmall: true);
      case TontineStatus.suspendue:
        return const TontiBadge(label: 'Suspendue', variant: BadgeVariant.danger, isSmall: true);
      case TontineStatus.cloturee:
        return const TontiBadge(label: 'Clôturée', variant: BadgeVariant.neutral, isSmall: true);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 48, color: TontiColors.textMuted),
            const SizedBox(height: 12),
            Text('Aucune tontine trouvée pour ce critère', style: TontiTypography.headingMedium),
            const SizedBox(height: 6),
            const Text('Essayez de modifier votre recherche ou créez une nouvelle tontine.'),
          ],
        ),
      ),
    );
  }
}

