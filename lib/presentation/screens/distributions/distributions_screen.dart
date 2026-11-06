import 'package:flutter/material.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../models/tontine_model.dart';
import '../../../models/distribution_model.dart';
import '../../widgets/common/tonti_card.dart';
import '../../widgets/common/tonti_button.dart';
import '../../widgets/common/tonti_badge.dart';
import '../../widgets/common/receipt_dialog.dart';
import '../../../data/datasources/local_tonti_datasource.dart';
import '../../../domain/entities/tontine_entity.dart';
import '../../../domain/entities/distribution_entity.dart';

class DistributionsScreen extends StatefulWidget {
  final String activeRole;

  const DistributionsScreen({
    super.key,
    required this.activeRole,
  });

  @override
  State<DistributionsScreen> createState() => _DistributionsScreenState();
}

class _DistributionsScreenState extends State<DistributionsScreen> {
  String? _signingDistributionId;
  String? _selectedTontineId;
  String _searchQuery = '';
  String _selectedStatusFilter = 'TOUS';

  void _showScheduleTurnDialog(BuildContext context, DistributionEntity dist) {
    final timeController = TextEditingController(text: '14:30');
    final dayController = TextEditingController(text: dist.scheduledDate.day.toString());
    String selectedDayOfWeek = 'Samedi';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Planifier - ${dist.beneficiaryName}', style: TontiTypography.headingMedium),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mois (automatique) : ${dist.scheduledDate.month}/${dist.scheduledDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: TontiColors.primaryGold),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: dayController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jour du mois (1-31)',
                    suffixText: 'du mois',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedDayOfWeek,
                  decoration: InputDecoration(
                    labelText: 'Jour de la semaine',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Lundi', child: Text('Lundi')),
                    DropdownMenuItem(value: 'Mardi', child: Text('Mardi')),
                    DropdownMenuItem(value: 'Mercredi', child: Text('Mercredi')),
                    DropdownMenuItem(value: 'Jeudi', child: Text('Jeudi')),
                    DropdownMenuItem(value: 'Vendredi', child: Text('Vendredi')),
                    DropdownMenuItem(value: 'Samedi', child: Text('Samedi')),
                    DropdownMenuItem(value: 'Dimanche', child: Text('Dimanche')),
                  ],
                  onChanged: (v) => selectedDayOfWeek = v ?? 'Samedi',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: 'Heure de distribution (ex: 15:00)',
                    hintText: '15:00',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TontiColors.primaryGold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final day = int.tryParse(dayController.text) ?? dist.scheduledDate.day;
              final newDate = DateTime(
                dist.scheduledDate.year,
                dist.scheduledDate.month,
                day.clamp(1, 31),
              );
              setState(() {
                final idx = LocalTontiDataSource().distributions.indexWhere((d) => d.id == dist.id);
                if (idx != -1) {
                  LocalTontiDataSource().distributions[idx] = dist.copyWith(
                    scheduledDate: newDate,
                  );
                }
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Distribution planifiée le $selectedDayOfWeek $day/${dist.scheduledDate.month}/${dist.scheduledDate.year} à ${timeController.text} !'),
                  backgroundColor: TontiColors.successGreen,
                ),
              );
            },
            child: const Text('Enregistrer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard(List<TontineModel> tontines) {
    final hasActiveFilter = _selectedTontineId != null || _searchQuery.isNotEmpty || _selectedStatusFilter != 'TOUS';

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
                'Filtre & Sélection de Tontine',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: TontiColors.textPrimary),
              ),
              if (hasActiveFilter) ...[
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedTontineId = null;
                      _searchQuery = '';
                      _selectedStatusFilter = 'TOUS';
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
                          child: _buildTontineDropdown(tontines),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 5,
                          child: _buildSearchInput(),
                        ),
                      ],
                    )
                  else ...[
                    _buildTontineDropdown(tontines),
                    const SizedBox(height: 10),
                    _buildSearchInput(),
                  ],
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatusChip('TOUS', 'Toutes les distributions'),
                        const SizedBox(width: 8),
                        _buildStatusChip('EN_COLLECTE', 'En collecte'),
                        const SizedBox(width: 8),
                        _buildStatusChip('VALIDEES', 'Validées & prêt'),
                        const SizedBox(width: 8),
                        _buildStatusChip('DISTRIBUÉES', 'Distribuées'),
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

  Widget _buildTontineDropdown(List<TontineModel> tontines) {
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
          value: _selectedTontineId,
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
            ...tontines.map((t) => DropdownMenuItem<String?>(
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
              _selectedTontineId = val;
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
        onChanged: (val) => setState(() => _searchQuery = val.trim()),
        decoration: const InputDecoration(
          hintText: 'Rechercher un bénéficiaire...',
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

  Widget _buildStatusChip(String key, String label) {
    final isSelected = _selectedStatusFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedStatusFilter = key);
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final dataSource = LocalTontiDataSource();
    final allTontines = dataSource.tontines;

    // Filtrage des tontines selon le selecteur de tontine
    final filteredTontines = allTontines.where((t) {
      if (_selectedTontineId != null && _selectedTontineId!.isNotEmpty) {
        if (t.id != _selectedTontineId) return false;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Calendrier des Distributions', style: TontiTypography.displayMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Ordre de passage des bénéficiaires, disponibilité de trésorerie et double signature pour chaque tontine',
                        style: TontiTypography.bodySmall,
                      ),
                    ],
                  ),
                  TontiBadge(
                    label: 'Double signature active',
                    variant: BadgeVariant.gold,
                    icon: Icons.security,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Barre de filtre & Select Tontine
              _buildFilterCard(allTontines),
              const SizedBox(height: 24),

              if (allTontines.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: TontiColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TontiColors.border),
                  ),
                  child: const Center(
                    child: Text(
                      'Aucune tontine créée.',
                      style: TextStyle(color: TontiColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              else if (filteredTontines.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: TontiColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: TontiColors.border),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 40, color: TontiColors.textMuted),
                        SizedBox(height: 10),
                        Text('Aucune tontine ne correspond au filtre sélectionné.', style: TextStyle(fontWeight: FontWeight.w600, color: TontiColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else
                ...filteredTontines.map((tontine) {
                  final tid = LocalTontiDataSource.numericId(tontine.id);
                  final members = tontine.members;

                  // Distributions de cette tontine avec filtres de statut et de recherche
                  final distributions = dataSource.distributions.where((d) {
                    final dtid = LocalTontiDataSource.numericId(d.tontineId);
                    final isSameTontine = dtid == tid || d.tontineName == tontine.name;
                    if (!isSameTontine) return false;

                    // Filtre par nom du bénéficiaire
                    if (_searchQuery.isNotEmpty &&
                        !d.beneficiaryName.toLowerCase().contains(_searchQuery.toLowerCase())) {
                      return false;
                    }

                    // Filtre par statut
                    if (_selectedStatusFilter == 'EN_COLLECTE') {
                      return d.status == DistributionStatus.enCollecte;
                    } else if (_selectedStatusFilter == 'VALIDEES') {
                      return d.status == DistributionStatus.validee;
                    } else if (_selectedStatusFilter == 'DISTRIBUÉES') {
                      return d.status == DistributionStatus.distribuee;
                    }
                    return true;
                  }).toList()..sort((a, b) => a.turnNumber.compareTo(b.turnNumber));

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête de la tontine
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: TontiColors.primaryGold.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: TontiColors.primaryGold.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.account_balance_wallet, color: TontiColors.primaryGold, size: 22),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Tontine : ${tontine.name}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: TontiColors.textPrimary),
                                  ),
                                ],
                              ),
                              TontiBadge(
                                label: '${tontine.memberCount} membres • ${tontine.coverTag}',
                                variant: BadgeVariant.gold,
                                isSmall: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Ordre de passage officiel des membres pour cette tontine
                        Text('Ordre de passage officiel des membres', style: TontiTypography.headingMedium),
                        const SizedBox(height: 10),
                        if (members.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: TontiColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: TontiColors.border),
                            ),
                            child: const Text('Aucun membre dans cette tontine.', style: TextStyle(color: TontiColors.textSecondary)),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: TontiColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: TontiColors.border),
                            ),
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: members.asMap().entries.map((entry) {
                                final idx = entry.key + 1;
                                final m = entry.value;
                                return Chip(
                                  avatar: CircleAvatar(
                                    backgroundColor: TontiColors.goldSoft,
                                    child: Text('$idx', style: const TextStyle(color: TontiColors.darkGold, fontWeight: FontWeight.w800, fontSize: 11)),
                                  ),
                                  label: Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                                  backgroundColor: TontiColors.background,
                                  side: const BorderSide(color: TontiColors.border),
                                );
                              }).toList(),
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Distributions planifiées pour cette tontine
                        Text('Distributions planifiées', style: TontiTypography.headingMedium),
                        const SizedBox(height: 10),
                        if (distributions.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: TontiColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: TontiColors.border),
                            ),
                            child: const Center(
                              child: Text(
                                'Aucun ordre de passage ou distribution ne correspond à vos critères.',
                                style: TextStyle(color: TontiColors.textSecondary, fontWeight: FontWeight.w600),
                              ),
                            ),
                          )
                        else
                          ...distributions.map((dist) {
                            final isCurrent = dist.status == DistributionStatus.enCollecte;
                            final isFunded = dist.isFullyFunded;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: TontiCard(
                                padding: const EdgeInsets.all(22),
                                hasGoldBorder: isCurrent,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 22,
                                              backgroundColor: isCurrent ? TontiColors.primaryGold : TontiColors.surfaceMuted,
                                              child: Icon(
                                                Icons.event,
                                                color: isCurrent ? Colors.white : TontiColors.textPrimary,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(dist.beneficiaryName, style: TontiTypography.headingMedium),
                                                    const SizedBox(width: 8),
                                                    TontiBadge(
                                                      label: dist.statusLabel,
                                                      variant: dist.status == DistributionStatus.distribuee
                                                          ? BadgeVariant.success
                                                          : BadgeVariant.gold,
                                                      isSmall: true,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${dist.tontineName} • Échéance : ${dist.scheduledDate.day}/${dist.scheduledDate.month}/${dist.scheduledDate.year}',
                                                  style: TontiTypography.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text('Montant de la cagnotte', style: TextStyle(fontSize: 11, color: TontiColors.textSecondary)),
                                            Text(
                                              Formatters.formatFCFA(dist.netAmount),
                                              style: TontiTypography.amountMedium.copyWith(color: TontiColors.primaryGold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: TontiColors.background,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: TontiColors.border),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Fonds rapprochés disponibles : ${Formatters.formatFCFA(dist.availableAmount)} / ${Formatters.formatFCFA(dist.theoreticalAmount)}',
                                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                          ),
                                          if (!isFunded && isCurrent)
                                            const Text(
                                              'Alerte : Déficit temporaire de trésorerie',
                                              style: TextStyle(fontSize: 11, color: TontiColors.alertRed, fontWeight: FontWeight.w700),
                                            )
                                          else if (dist.status == DistributionStatus.distribuee)
                                            const Text(
                                              'Décaissé par MTN MoMo',
                                              style: TextStyle(fontSize: 11, color: TontiColors.successGreen, fontWeight: FontWeight.w600),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            _buildSignaturePill(
                                              'Président',
                                              dist.approvedByPresident != null,
                                              dist.approvedByPresident,
                                            ),
                                            const SizedBox(width: 12),
                                            _buildSignaturePill(
                                              'Trésorier',
                                              dist.approvedByTreasurer != null,
                                              dist.approvedByTreasurer,
                                            ),
                                          ],
                                        ),
                                        if (widget.activeRole == 'Président' || widget.activeRole == 'Trésorier') ...[
                                          const SizedBox(width: 8),
                                          OutlinedButton.icon(
                                            onPressed: () => _showScheduleTurnDialog(context, dist),
                                            icon: const Icon(Icons.calendar_today, size: 16),
                                            label: const Text('Planifier Heure/Jour'),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              minimumSize: Size.zero,
                                            ),
                                          ),
                                        ],
                                        if (dist.status == DistributionStatus.enCollecte)
                                          (widget.activeRole == 'Président' || widget.activeRole == 'Trésorier')
                                              ? TontiButton(
                                                  label: 'Exécuter la distribution',
                                                  icon: Icons.check,
                                                  height: 36,
                                                  onPressed: _signingDistributionId != null
                                                      ? null
                                                      : () async {
                                                    final user = LocalTontiDataSource().currentUser;
                                                    final compenser = await showDialog<bool>(
                                                      context: context,
                                                      builder: (ctx) => AlertDialog(
                                                        title: const Text('Exécuter la distribution'),
                                                        content: Text(
                                                          'Compenser automatiquement les dettes de ${dist.beneficiaryName} '
                                                          '(cotisations impayées, pénalités, échéances de prêt) avant le versement du solde net ?',
                                                        ),
                                                        actions: [
                                                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
                                                          OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Sans compensation')),
                                                          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Avec compensation')),
                                                        ],
                                                      ),
                                                    );
                                                    if (compenser == null || !mounted) return;
                                                    setState(() => _signingDistributionId = dist.id);
                                                    final signed = await LocalTontiDataSource().signDistribution(
                                                      distributionId: dist.id,
                                                      performedByUser: user,
                                                      compenserDettes: compenser,
                                                    );
                                                    if (!mounted) return;
                                                    setState(() => _signingDistributionId = null);
                                                    if (!signed) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            LocalTontiDataSource().lastSyncError ??
                                                                'L\'exécution n\'a pas été acceptée par le serveur.',
                                                          ),
                                                          backgroundColor: TontiColors.alertRed,
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    setState(() {});
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Distribution exécutée par ${user.fullName} (${widget.activeRole}).'),
                                                        backgroundColor: TontiColors.successGreen,
                                                      ),
                                                    );
                                                  },
                                                )
                                              : const TontiBadge(
                                                  label: 'Signature réservée au Bureau (Président / Trésorier)',
                                                  variant: BadgeVariant.neutral,
                                                  isSmall: true,
                                                )
                                        else if (dist.status == DistributionStatus.validee &&
                                            dist.beneficiaryName == LocalTontiDataSource().currentUser.fullName)
                                          TontiButton(
                                            label: 'Confirmer la réception',
                                            icon: Icons.verified,
                                            height: 36,
                                            onPressed: () async {
                                              final ok = await LocalTontiDataSource().confirmDistribution(dist.id);
                                              if (!mounted) return;
                                              setState(() {});
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(ok ? 'Réception confirmée.' : 'Le serveur a refusé la confirmation.'),
                                                  backgroundColor: ok ? TontiColors.successGreen : TontiColors.alertRed,
                                                ),
                                              );
                                            },
                                          )
                                        else if (dist.status == DistributionStatus.distribuee)
                                          OutlinedButton.icon(
                                            onPressed: () => ReceiptDialog.show(
                                              context,
                                              title: 'Reçu de Distribution',
                                              reference: dist.id,
                                              memberName: dist.beneficiaryName,
                                              tontineName: dist.tontineName,
                                              amount: dist.netAmount,
                                              paymentMethod: 'Mobile Money (MTN / Orange)',
                                              date: dist.scheduledDate,
                                              note: 'Distribution officielle',
                                            ),
                                            icon: const Icon(Icons.download, size: 16),
                                            label: const Text('Reçu officiel PDF'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
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

  Widget _buildSignaturePill(String role, bool isSigned, String? signer) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSigned ? TontiColors.successSoft : TontiColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSigned ? TontiColors.successGreen.withOpacity(0.3) : TontiColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSigned ? Icons.check_circle : Icons.pending_outlined,
            size: 14,
            color: isSigned ? TontiColors.successGreen : TontiColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            isSigned ? '$role : $signer' : '$role : En attente',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSigned ? TontiColors.successGreen : TontiColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
