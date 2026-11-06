import 'package:flutter/material.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../presentation/controllers/auth_controller.dart';

class _SidebarGroup {
  final String title;
  final IconData icon;
  final List<List<dynamic>> items;

  const _SidebarGroup({
    required this.title,
    required this.icon,
    required this.items,
  });
}

class TontiSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final String activeRole;
  final VoidCallback onRoleSwitchRequested;

  const TontiSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.activeRole,
    required this.onRoleSwitchRequested,
  });

  @override
  Widget build(BuildContext context) {
    final groups = const [
      _SidebarGroup(
        title: 'Espace Principal',
        icon: Icons.space_dashboard_outlined,
        items: [
          [0, 'Tableau de bord', Icons.dashboard_outlined, Icons.dashboard],
          [1, 'Mes Tontines', Icons.account_balance_outlined, Icons.account_balance],
        ],
      ),
      _SidebarGroup(
        title: 'Gestion & Finances',
        icon: Icons.account_balance_wallet_outlined,
        items: [
          [2, 'Cotisations & Paiements', Icons.payments_outlined, Icons.payments],
          [3, 'Distributions', Icons.sync_alt_outlined, Icons.sync_alt],
          [4, 'Caisse & Comptabilité', Icons.savings_outlined, Icons.savings],
        ],
      ),
      _SidebarGroup(
        title: 'Vie du Groupe & Services',
        icon: Icons.groups_outlined,
        items: [
          [5, 'Prêts & Entraide', Icons.handshake_outlined, Icons.handshake],
          [6, 'Réunions Présentielles', Icons.groups_outlined, Icons.groups],
        ],
      ),
      _SidebarGroup(
        title: 'Paramètres & Profil',
        icon: Icons.settings_outlined,
        items: [
          [7, 'Paramètres & Profil', Icons.settings_outlined, Icons.settings],
        ],
      ),
    ];

    return Container(
      width: 270,
      decoration: const BoxDecoration(
        color: TontiColors.white,
        border: Border(
          right: BorderSide(color: TontiColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo & Nom de l'application
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [TontiColors.primaryGold, TontiColors.darkGold],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: TontiColors.primaryGold.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.diversity_3_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'Tonti',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: TontiColors.textPrimary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Link',
                            style: TextStyle(
                              color: TontiColors.primaryGold,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'FinTech des Tontines CM',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: TontiColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Accordeons de navigation
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: groups.length,
              itemBuilder: (context, gIdx) {
                final group = groups[gIdx];
                final containsSelected = group.items.any((it) => (it[0] as int) == selectedIndex);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: containsSelected ? TontiColors.goldSoft.withOpacity(0.4) : TontiColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: containsSelected ? TontiColors.primaryGold.withOpacity(0.3) : TontiColors.border,
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: PageStorageKey<String>('shared_acc_${group.title}'),
                      initiallyExpanded: containsSelected || gIdx == 0,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      childrenPadding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                      leading: Icon(
                        group.icon,
                        size: 19,
                        color: containsSelected ? TontiColors.darkGold : TontiColors.textSecondary,
                      ),
                      title: Text(
                        group.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: containsSelected ? TontiColors.darkGold : TontiColors.textPrimary,
                        ),
                      ),
                      children: group.items.map((it) {
                        final idx = it[0] as int;
                        final label = it[1] as String;
                        final unselectedIcon = it[2] as IconData;
                        final selectedIcon = it[3] as IconData;
                        final isSelected = selectedIndex == idx;

                        return _buildNavItem(
                          idx,
                          label,
                          unselectedIcon,
                          selectedIcon,
                          isSelected,
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Bouton Déconnexion au bas de la barre latérale
          Padding(
            padding: const EdgeInsets.all(12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => AuthController().logout(),
                borderRadius: BorderRadius.circular(12),
                hoverColor: TontiColors.alertRed.withOpacity(0.08),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: TontiColors.alertSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: TontiColors.alertRed,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Déconnexion',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: TontiColors.alertRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    IconData unselectedIcon,
    IconData selectedIcon,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected ? TontiColors.goldSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => onDestinationSelected(index),
          borderRadius: BorderRadius.circular(10),
          hoverColor: TontiColors.primaryGold.withOpacity(0.06),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: TontiColors.primaryGold.withOpacity(0.4))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : unselectedIcon,
                  size: 19,
                  color: isSelected ? TontiColors.darkGold : TontiColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? TontiColors.textPrimary : TontiColors.textSecondary,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: TontiColors.primaryGold,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
