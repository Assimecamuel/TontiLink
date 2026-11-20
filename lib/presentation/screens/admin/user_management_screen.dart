import 'package:flutter/material.dart' hide Text;
import '../../../core/i18n/tonti_text.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/datasources/local_tonti_datasource.dart';
import '../../../domain/entities/user_entity.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/tonti_badge.dart';
import '../../widgets/common/tonti_card.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final LocalTontiDataSource _dataSource = LocalTontiDataSource();
  String _searchQuery = '';
  String _selectedFilter = 'Tous'; // Tous, En ligne, Actifs, Désactivés, Super Admin

  @override
  void initState() {
    super.initState();
    _loadDbUsers();
  }

  Future<void> _loadDbUsers() async {
    await _dataSource.syncFromBackend();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final currentUser = AuthController().currentUser ?? _dataSource.currentUser;
    final isSuperAdmin = currentUser.isSuperAdmin || AuthController().activeRole == UserRole.superAdmin;

    if (!isSuperAdmin) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: TontiCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.security, size: 60, color: TontiColors.alertRed),
                const SizedBox(height: 16),
                Text(tr('Accès Restreint — Privilège Super Admin Requis'), style: TontiTypography.headingMedium, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  tr('Seul le Super Administrateur de la plateforme possède les droits nécessaires pour visualiser la liste des utilisateurs, gérer leur statut (activer/désactiver) ou supprimer des comptes.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TontiColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final allUsers = _dataSource.platformUsers;

    // Calcul des statistiques
    final totalUsers = allUsers.length;
    final onlineCount = allUsers.where((u) => u.isOnline).length;
    final activeCount = allUsers.where((u) => u.isActive).length;
    final disabledCount = allUsers.where((u) => !u.isActive).length;

    // Filtrage des utilisateurs
    final filteredUsers = allUsers.where((u) {
      final matchesSearch = u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.phone.contains(_searchQuery) ||
          u.roleDisplayName.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_selectedFilter == 'En ligne') return u.isOnline;
      if (_selectedFilter == 'Actifs') return u.isActive;
      if (_selectedFilter == 'Désactivés') return !u.isActive;
      if (_selectedFilter == 'Super Admin') return u.isSuperAdmin;

      return true;
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 28 : (isMobile ? 12 : 18)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête réactif
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.admin_panel_settings, color: TontiColors.primaryGold, size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(tr('Supervision & Comptes'), style: TontiTypography.headingLarge),
                        ),
                        TontiBadge(
                          label: tr('Super Admin'),
                          variant: BadgeVariant.gold,
                          icon: Icons.shield,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tr('Contrôlez les utilisateurs de la plateforme, voyez qui est en ligne, désactivez ou supprimez des comptes.'),
                      style: TontiTypography.bodySmall,
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.admin_panel_settings, color: TontiColors.primaryGold, size: 32),
                              const SizedBox(width: 12),
                              Text(tr('Supervision & Gestion des Comptes'), style: TontiTypography.displayMedium),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tr('Contrôlez les utilisateurs de la plateforme, voyez qui est en ligne, désactivez ou supprimez des comptes.'),
                            style: TontiTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    TontiBadge(
                      label: tr('Super Admin'),
                      variant: BadgeVariant.gold,
                      icon: Icons.shield,
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // Cartes de statistiques sécurisées contre les erreurs de contraintes
              LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  if (w <= 0) return const SizedBox.shrink();

                  if (w < 500) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildStatBox(tr('Total Comptes'), '$totalUsers', Icons.people_outline, TontiColors.infoBlue)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildStatBox(tr('En ligne 🟢'), '$onlineCount', Icons.wifi_tethering, TontiColors.successGreen)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _buildStatBox(tr('Comptes Actifs'), '$activeCount', Icons.check_circle_outline, TontiColors.primaryGold)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildStatBox(tr('Désactivés 🔴'), '$disabledCount', Icons.block_outlined, TontiColors.alertRed)),
                          ],
                        ),
                      ],
                    );
                  }

                  final cardWidth = w > 800 ? (w - 42) / 4 : (w - 14) / 2;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      _buildStatBox(tr('Total Comptes'), '$totalUsers', Icons.people_outline, TontiColors.infoBlue, width: cardWidth),
                      _buildStatBox(tr('En ligne 🟢'), '$onlineCount', Icons.wifi_tethering, TontiColors.successGreen, width: cardWidth),
                      _buildStatBox(tr('Comptes Actifs'), '$activeCount', Icons.check_circle_outline, TontiColors.primaryGold, width: cardWidth),
                      _buildStatBox(tr('Désactivés 🔴'), '$disabledCount', Icons.block_outlined, TontiColors.alertRed, width: cardWidth),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Barre de recherche et filtres
              TontiCard(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: tr('Rechercher par nom, téléphone, email ou rôle...'),
                        prefixIcon: Icon(Icons.search, color: TontiColors.textMuted),
                        filled: true,
                        fillColor: TontiColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Tous'),
                          _buildFilterChip('En ligne'),
                          _buildFilterChip('Actifs'),
                          _buildFilterChip('Désactivés'),
                          _buildFilterChip('Super Admin'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Liste des cartes d'utilisateurs sans ListView unconstrained
              if (filteredUsers.isEmpty)
                TontiCard(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.person_off_outlined, size: 44, color: TontiColors.textMuted),
                        const SizedBox(height: 10),
                        Text(tr('Aucun utilisateur ne correspond à votre recherche.'), style: TontiTypography.headingMedium, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: filteredUsers.map((user) => _buildUserCard(user, isMobile)).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color, {double? width}) {
    final card = TontiCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: TontiTypography.headingLarge.copyWith(color: color, fontWeight: FontWeight.bold)),
                Text(label, style: TextStyle(fontSize: 11.5, color: TontiColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );

    if (width != null && width > 0) {
      return SizedBox(width: width, child: card);
    }
    return card;
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(tr(label)),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedFilter = label),
        selectedColor: TontiColors.primaryGold,
        backgroundColor: TontiColors.background,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : TontiColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12.5,
        ),
      ),
    );
  }

  Widget _buildUserCard(UserEntity user, bool isMobile) {
    if (isMobile) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: TontiCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: user.isSuperAdmin
                            ? TontiColors.primaryGold
                            : (user.isActive ? TontiColors.infoBlue : TontiColors.textMuted),
                        child: Text(
                          user.avatarInitials,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: user.isOnline ? TontiColors.successGreen : Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(user.fullName, style: TontiTypography.headingMedium),
                            TontiBadge(
                              label: user.roleDisplayName,
                              variant: user.isSuperAdmin ? BadgeVariant.gold : BadgeVariant.neutral,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${user.phone}${user.email.isNotEmpty ? " • ${user.email}" : ""}',
                          style: TextStyle(fontSize: 12, color: TontiColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              user.isActive ? Icons.check_circle : Icons.block,
                              size: 13,
                              color: user.isActive ? TontiColors.successGreen : TontiColors.alertRed,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.isActive ? tr('Compte Actif') : tr('Compte Désactivé'),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: user.isActive ? TontiColors.successGreen : TontiColors.alertRed,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (user.isOnline)
                              Text('• 🟢 ${tr("En ligne")}', style: TextStyle(fontSize: 11, color: TontiColors.successGreen, fontWeight: FontWeight.bold))
                            else if (user.lastSeen != null)
                              Text('• ${user.lastSeen}', style: TextStyle(fontSize: 11, color: TontiColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _confirmToggleActive(user),
                    icon: Icon(
                      user.isActive ? Icons.block : Icons.check_circle_outline,
                      size: 16,
                      color: user.isActive ? TontiColors.alertRed : TontiColors.successGreen,
                    ),
                    label: Text(
                      user.isActive ? tr('Désactiver') : tr('Réactiver'),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: user.isActive ? TontiColors.alertRed : TontiColors.successGreen,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: Icon(Icons.manage_accounts_outlined, color: TontiColors.primaryGold, size: 20),
                    onPressed: () => _showChangeRoleDialog(user),
                    tooltip: tr('Rôle'),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: TontiColors.alertRed, size: 20),
                    onPressed: () => _confirmDeleteUser(user),
                    tooltip: tr('Supprimer'),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Vue Desktop / Tablette
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TontiCard(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: user.isSuperAdmin
                      ? TontiColors.primaryGold
                      : (user.isActive ? TontiColors.infoBlue : TontiColors.textMuted),
                  child: Text(
                    user.avatarInitials,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: user.isOnline ? TontiColors.successGreen : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(user.fullName, style: TontiTypography.headingMedium),
                      TontiBadge(
                        label: user.roleDisplayName,
                        variant: user.isSuperAdmin ? BadgeVariant.gold : BadgeVariant.neutral,
                      ),
                      if (user.isOnline)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: TontiColors.successSoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 8, color: TontiColors.successGreen),
                              const SizedBox(width: 4),
                              Text(tr('En ligne'), style: TextStyle(fontSize: 11, color: TontiColors.successGreen, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        )
                      else if (user.lastSeen != null)
                        Text(user.lastSeen!, style: TextStyle(fontSize: 11, color: TontiColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.phone} • ${user.email.isNotEmpty ? user.email : "Pas d'email"}',
                    style: TextStyle(fontSize: 12.5, color: TontiColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        user.isActive ? Icons.check_circle : Icons.block,
                        size: 14,
                        color: user.isActive ? TontiColors.successGreen : TontiColors.alertRed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.isActive ? tr('Compte Actif') : tr('Compte Désactivé'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: user.isActive ? TontiColors.successGreen : TontiColors.alertRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Tooltip(
                  message: user.isActive ? tr('Désactiver ce compte') : tr('Réactiver ce compte'),
                  child: IconButton(
                    icon: Icon(
                      user.isActive ? Icons.toggle_on : Icons.toggle_off,
                      size: 36,
                      color: user.isActive ? TontiColors.successGreen : TontiColors.textMuted,
                    ),
                    onPressed: () => _confirmToggleActive(user),
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: tr('Changer le rôle'),
                  child: IconButton(
                    icon: Icon(Icons.manage_accounts_outlined, color: TontiColors.primaryGold),
                    onPressed: () => _showChangeRoleDialog(user),
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: tr('Supprimer le compte'),
                  child: IconButton(
                    icon: Icon(Icons.delete_outline, color: TontiColors.alertRed),
                    onPressed: () => _confirmDeleteUser(user),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmToggleActive(UserEntity user) {
    final willDisable = user.isActive;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(willDisable ? tr('Désactiver le compte ?') : tr('Réactiver le compte ?')),
        content: Text(
          willDisable
              ? tr('Voulez-vous vraiment désactiver le compte de {name} ? L\'utilisateur ne pourra plus accéder à l\'application.', {'name': user.fullName})
              : tr('Voulez-vous réactiver le compte de {name} ? L\'utilisateur pourra à nouveau se connecter.', {'name': user.fullName}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('Annuler')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: willDisable ? TontiColors.alertRed : TontiColors.successGreen,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _dataSource.toggleUserActiveStatus(user.id, !willDisable);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    willDisable
                        ? tr('Compte de {name} désactivé.', {'name': user.fullName})
                        : tr('Compte de {name} réactivé.', {'name': user.fullName}),
                  ),
                  backgroundColor: willDisable ? TontiColors.alertRed : TontiColors.successGreen,
                ),
              );
            },
            child: Text(willDisable ? tr('Désactiver') : tr('Réactiver'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(UserEntity user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: TontiColors.alertRed),
            const SizedBox(width: 8),
            Text(tr('Supprimer le compte ?')),
          ],
        ),
        content: Text(
          tr('Êtes-vous sûr de vouloir SUPPRIMER DÉFINITIVEMENT le compte de {name} ({email}) ? Cette action est irréversible.', {'name': user.fullName, 'email': user.email}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('Annuler')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: TontiColors.alertRed),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _dataSource.deleteUserAccount(user.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('Le compte de {name} a été supprimé.', {'name': user.fullName})),
                  backgroundColor: TontiColors.alertRed,
                ),
              );
            },
            child: Text(tr('Supprimer définitivement'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(UserEntity user) {
    UserRole selectedRole = user.activeRole;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(tr('Modifier le rôle de {name}', {'name': user.fullName})),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: UserRole.values.map((role) {
              String name;
              switch (role) {
                case UserRole.superAdmin:
                  name = 'Super Admin';
                  break;
                case UserRole.president:
                  name = 'Président';
                  break;
                case UserRole.tresorier:
                  name = 'Trésorier';
                  break;
                case UserRole.secretaire:
                  name = 'Secrétaire';
                  break;
                case UserRole.commissaire:
                  name = 'Commissaire aux comptes';
                  break;
                case UserRole.membre:
                  name = 'Membre';
                  break;
              }
              return RadioListTile<UserRole>(
                title: Text(name),
                value: role,
                groupValue: selectedRole,
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedRole = val);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('Annuler')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  final idx = _dataSource.platformUsers.indexWhere((u) => u.id == user.id);
                  if (idx != -1) {
                    _dataSource.platformUsers[idx] = _dataSource.platformUsers[idx].copyWith(activeRole: selectedRole);
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr('Rôle de {name} mis à jour.', {'name': user.fullName})),
                  ),
                );
              },
              child: Text(tr('Enregistrer')),
            ),
          ],
        ),
      ),
    );
  }
}
