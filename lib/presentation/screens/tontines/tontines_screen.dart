import 'package:flutter/material.dart';
import '../../../data/datasources/local_tonti_datasource.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../models/tontine_model.dart';
import '../../widgets/common/tonti_card.dart';
import '../../widgets/common/tonti_button.dart';
import '../../widgets/common/tonti_badge.dart';

class TontinesScreen extends StatefulWidget {
  final ValueChanged<TontineModel> onSelectTontine;
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
  String? selectedTontineId;
  String selectedFilter = 'Toutes';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final allTontines = LocalTontiDataSource().tontines;

    // Filtrage dynamique des tontines
    final filteredList = allTontines.where((t) {
      if (selectedTontineId != null && selectedTontineId!.isNotEmpty) {
        if (t.id != selectedTontineId) return false;
      }
      if (searchQuery.isNotEmpty &&
          !t.name.toLowerCase().contains(searchQuery.toLowerCase()) &&
          !t.description.toLowerCase().contains(searchQuery.toLowerCase())) {
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
                  Flexible(
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _openJoinDialog,
                          icon: const Icon(Icons.vpn_key_outlined, size: 18),
                          label: const Text('Rejoindre avec un code'),
                        ),
                        TontiButton(
                          label: 'Créer une tontine',
                          icon: Icons.add,
                          onPressed: widget.onCreateTontine,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Barre de filtres et recherche avec Selecteur de Tontines
              _buildFilterAndSearchBar(context, isDesktop, allTontines),
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

  /// Rejoindre une tontine avec un code d'invitation (devient simple membre).
  Future<void> _openJoinDialog() async {
    final ctrl = TextEditingController();
    String? error;
    bool loading = false;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Rejoindre une tontine'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 360,
              maxHeight: MediaQuery.of(ctx).size.height * 0.75,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ctrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Code d’invitation',
                      hintText: 'Ex. INV-123456',
                      prefixIcon: Icon(Icons.vpn_key_outlined),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(error!, style: const TextStyle(color: TontiColors.alertRed, fontSize: 13)),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: TontiColors.primaryGold),
              onPressed: loading
                  ? null
                  : () async {
                      final code = ctrl.text.trim();
                      if (code.isEmpty) {
                        setModal(() => error = 'Saisissez le code reçu.');
                        return;
                      }
                      setModal(() {
                        loading = true;
                        error = null;
                      });
                      final ds = LocalTontiDataSource();
                      final res = await ds.joinTontine(code);
                      if (!res.isOk) {
                        setModal(() {
                          loading = false;
                          error = res.message ?? 'Code invalide ou expiré.';
                        });
                        return;
                      }
                      await ds.syncFromBackend();
                      AuthController().updateCurrentUser(ds.currentUser);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
              child: const Text('Rejoindre'),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
    if (mounted) setState(() {});
  }

  Widget _buildFilterAndSearchBar(BuildContext context, bool isDesktop, List<TontineModel> allTontines) {
    final hasActiveFilter = selectedTontineId != null || searchQuery.isNotEmpty || selectedFilter != 'Toutes';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TontiColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TontiColors.border),
        boxShadow: [TontiColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: TontiColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Filtre & Sélection de Tontines',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: TontiColors.textPrimary),
              ),
              if (hasActiveFilter) ...[
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedTontineId = null;
                      searchQuery = '';
                      selectedFilter = 'Toutes';
                    });
                  },
                  icon: const Icon(Icons.clear_all_rounded, size: 16, color: TontiColors.alertRed),
                  label: const Text('Réinitialiser', style: TextStyle(fontSize: 12, color: TontiColors.alertRed, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 640;
              return Column(
                children: [
                  if (isWide)
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildTontineDropdown(allTontines),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 5,
                          child: _buildSearchInput(),
                        ),
                      ],
                    )
                  else ...[
                    _buildTontineDropdown(allTontines),
                    const SizedBox(height: 10),
                    _buildSearchInput(),
                  ],
                  const SizedBox(height: 12),
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
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTontineDropdown(List<TontineModel> allTontines) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: TontiColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TontiColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedTontineId,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: TontiColors.primaryGold),
          dropdownColor: TontiColors.white,
          hint: const Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, size: 18, color: TontiColors.primaryGold),
              SizedBox(width: 8),
              Text('Sélectionner une tontine...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: TontiColors.textPrimary)),
            ],
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Row(
                children: [
                  Icon(Icons.all_inclusive_rounded, size: 18, color: TontiColors.darkGold),
                  SizedBox(width: 8),
                  Text('Toutes les tontines', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: TontiColors.darkGold)),
                ],
              ),
            ),
            ...allTontines.map((t) => DropdownMenuItem<String?>(
              value: t.id,
              child: Row(
                children: [
                  const Icon(Icons.groups_outlined, size: 18, color: TontiColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: TontiColors.textPrimary),
                    ),
                  ),
                ],
              ),
            )),
          ],
          onChanged: (val) {
            setState(() {
              selectedTontineId = val;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: TontiColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TontiColors.border),
      ),
      child: TextField(
        onChanged: (val) => setState(() => searchQuery = val.trim()),
        decoration: const InputDecoration(
          hintText: 'Rechercher par nom ou ville...',
          hintStyle: TextStyle(fontSize: 13, color: TontiColors.textSecondary),
          prefixIcon: Icon(Icons.search, color: TontiColors.textSecondary, size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 13),
        ),
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
        fontSize: 12.5,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? TontiColors.darkGold : TontiColors.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? TontiColors.primaryGold : TontiColors.border,
      ),
    );
  }

  Widget _buildTontineCard(TontineModel tontine) {
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
