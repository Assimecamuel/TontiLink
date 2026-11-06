import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/public_palette.dart';
import '../../controllers/auth_controller.dart';
import '../common/public_controls.dart';

/// Section Accordion pour la barre latérale
class _SidebarAccordionGroup {
  final String title;
  final IconData icon;
  final List<List<dynamic>> items;

  const _SidebarAccordionGroup({
    required this.title,
    required this.icon,
    required this.items,
  });
}

/// Barre latérale or & noir chaud avec catégories Accordéon réductibles et bouton Déconnexion en bas.
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
    final roleLower = activeRole.toLowerCase();
    final isPresident = roleLower.contains('président') || roleLower.contains('president');
    final isSecretary = roleLower.contains('secrétaire') || roleLower.contains('secretaire');
    final isTreasurer = roleLower.contains('trésorier') || roleLower.contains('tresorier');
    final isAuditor = roleLower.contains('commissaire');

    // Définition des groupes accordéon avec traductions i18n
    final List<_SidebarAccordionGroup> accordionGroups;

    if (isSecretary) {
      accordionGroups = [
        _SidebarAccordionGroup(
          title: 'Espace Secrétariat',
          icon: Icons.edit_note_rounded,
          items: [
            [0, 'nav_sec_space', Icons.edit_note_rounded],
            [1, 'nav_sec_members', Icons.people_outline_rounded],
          ],
        ),
        _SidebarAccordionGroup(
          title: 'Vie du Groupe',
          icon: Icons.groups_rounded,
          items: [
            [6, 'nav_sec_meetings', Icons.groups_rounded],
            [2, 'nav_sec_penalties', Icons.warning_amber_rounded],
          ],
        ),
        _SidebarAccordionGroup(
          title: 'Configuration',
          icon: Icons.settings_rounded,
          items: [
            [7, 'nav_settings', Icons.settings_rounded],
          ],
        ),
      ];
    } else if (isTreasurer) {
      accordionGroups = [
        _SidebarAccordionGroup(
          title: 'Gestion Trésorerie',
          icon: Icons.account_balance_wallet_rounded,
          items: [
            [0, 'nav_treas_space', Icons.account_balance_wallet_rounded],
            [2, 'nav_treas_validation', Icons.fact_check_rounded],
          ],
        ),
        _SidebarAccordionGroup(
          title: 'Flux Financiers',
          icon: Icons.savings_rounded,
          items: [
            [4, 'nav_treas_cash', Icons.savings_rounded],
            [3, 'nav_treas_distrib', Icons.sync_alt_rounded],
            [5, 'nav_treas_loans', Icons.handshake_rounded],
          ],
        ),
        _SidebarAccordionGroup(
          title: 'Configuration',
          icon: Icons.settings_rounded,
          items: [
            [7, 'nav_settings', Icons.settings_rounded],
          ],
        ),
      ];
    } else if (isAuditor) {
      accordionGroups = [
        _SidebarAccordionGroup(
          title: 'Espace Audit',
          icon: Icons.find_in_page_rounded,
          items: [
            [0, 'nav_aud_space', Icons.find_in_page_rounded],
            [2, 'nav_aud_contrib', Icons.payments_rounded],
          ],
        ),
        _SidebarAccordionGroup(
          title: 'Contrôle Caisse',
          icon: Icons.savings_rounded,
          items: [
            [4, 'nav_aud_cash', Icons.savings_rounded],
            [3, 'nav_aud_distrib', Icons.sync_alt_rounded],
          ],
        ),
        _SidebarAccordionGroup(
          title: 'Configuration',
          icon: Icons.settings_rounded,
          items: [
            [7, 'nav_settings', Icons.settings_rounded],
          ],
        ),
      ];
    } else if (!isPresident) {
      // Membre Simple
      accordionGroups = [
        _SidebarAccordionGroup(
          title: 'Espace Membre',
          icon: Icons.person_rounded,
          items: [
            [0, 'nav_mem_space', Icons.person_rounded],
            [1, 'nav_mem_tontines', Icons.account_balance_rounded],
          ],
        ),
        _SidebarAccordionGroup(
          title: 'Cotisations & Services',
          icon: Icons.payments_rounded,
          items: [
            [2, 'nav_mem_pay', Icons.payments_rounded],
            [5, 'nav_mem_loans', Icons.handshake_rounded],
            [6, 'nav_mem_meetings', Icons.notifications_active_rounded],
          ],
        ),
        _SidebarAccordionGroup(
          title: 'Configuration',
          icon: Icons.settings_rounded,
          items: [
            [7, 'nav_settings', Icons.settings_rounded],
          ],
        ),
      ];
    } else {
      // Président (Vue complète structurée en accordéons)
      accordionGroups = [
        _SidebarAccordionGroup(
          title: 'Espace Principal',
          icon: Icons.space_dashboard_rounded,
          items: [
            [0, 'nav_dashboard', Icons.dashboard_rounded],
            [1, 'nav_tontines', Icons.account_balance_rounded],
          ],
        ),
        _SidebarAccordionGroup(
          title: 'Finances & Cotisations',
          icon: Icons.account_balance_wallet_rounded,
          items: [
            [2, 'nav_contrib', Icons.payments_rounded],
            [3, 'nav_distrib', Icons.sync_alt_rounded],
            [4, 'nav_cash', Icons.savings_rounded],
          ],
        ),
        _SidebarAccordionGroup(
          title: 'Services & Activités',
          icon: Icons.diversity_3_rounded,
          items: [
            [5, 'nav_loans', Icons.handshake_rounded],
            [6, 'nav_meetings', Icons.groups_rounded],
          ],
        ),
        _SidebarAccordionGroup(
          title: 'Système & Profil',
          icon: Icons.tune_rounded,
          items: [
            [7, 'nav_settings', Icons.settings_rounded],
          ],
        ),
      ];
    }

    return Container(
      width: 268,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF261C09), Color(0xFF130E05)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Logo TontiLink
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 26, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TontiLogo(size: 40, onDark: true),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 18, 24, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  tr('space_label'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white54,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
            ),

            // Accordéons de Navigation (remplace la liste simple)
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  unselectedWidgetColor: Colors.white54,
                  colorScheme: const ColorScheme.dark(primary: AppColors.primaryGold),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  itemCount: accordionGroups.length,
                  itemBuilder: (context, groupIdx) {
                    final group = accordionGroups[groupIdx];
                    final containsSelected = group.items.any((it) => (it[0] as int) == selectedIndex);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: containsSelected ? AppColors.primaryGold.withOpacity(0.3) : Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: ExpansionTile(
                        key: PageStorageKey<String>('accordion_${group.title}_$activeRole'),
                        initiallyExpanded: containsSelected || groupIdx == 0,
                        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        leading: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: containsSelected ? AppColors.primaryGold.withOpacity(0.2) : Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            group.icon,
                            size: 18,
                            color: containsSelected ? AppColors.lightGold : Colors.white70,
                          ),
                        ),
                        title: Text(
                          group.title,
                          style: TextStyle(
                            color: containsSelected ? AppColors.lightGold : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        trailing: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: containsSelected ? AppColors.primaryGold : Colors.white38,
                          size: 20,
                        ),
                        children: group.items.map((it) {
                          final idx = it[0] as int;
                          final isSelected = selectedIndex == idx;
                          return _NavItem(
                            label: tr(it[1] as String),
                            icon: it[2] as IconData,
                            selected: isSelected,
                            onTap: () => onDestinationSelected(idx),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Bouton Déconnexion au bas de la barre latérale
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => AuthController().logout(),
                  borderRadius: BorderRadius.circular(12),
                  hoverColor: AppColors.alertRed.withOpacity(0.15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.alertRed.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: AppColors.alertRed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          tr('logout'),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: Colors.white.withOpacity(0.06),
          child: Ink(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              gradient: selected ? kGoldGradient : null,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(icon, size: 19, color: selected ? Colors.white : Colors.white60),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? Colors.white : Colors.white70,
                    ),
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
