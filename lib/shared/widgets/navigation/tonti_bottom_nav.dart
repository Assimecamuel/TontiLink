import 'package:flutter/material.dart';
import '../../../core/theme/tonti_colors.dart';

class TontiSidebarOrBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const TontiSidebarOrBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TontiBottomNav(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
    );
  }
}

class TontiBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const TontiBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  void _showMoreModulesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        decoration: BoxDecoration(
          color: TontiColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [TontiColors.elevatedShadow],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TontiColors.goldSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.grid_view_rounded, color: TontiColors.darkGold, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Autres modules & services',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TontiColors.textPrimary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: TontiColors.border),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.6,
              children: [
                _buildMoreModuleCard(ctx, 3, 'Distributions', Icons.sync_alt_rounded),
                _buildMoreModuleCard(ctx, 4, 'Caisse', Icons.savings_outlined),
                _buildMoreModuleCard(ctx, 5, 'Prêts', Icons.handshake_outlined),
                _buildMoreModuleCard(ctx, 6, 'Réunions', Icons.groups_outlined),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreModuleCard(BuildContext context, int index, String label, IconData icon) {
    final isSelected = selectedIndex == index;
    return Material(
      color: isSelected ? TontiColors.goldSoft : TontiColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onDestinationSelected(index);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? TontiColors.primaryGold : TontiColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? TontiColors.darkGold : TontiColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? TontiColors.darkGold : TontiColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMoreActive = selectedIndex == 3 || selectedIndex == 4 || selectedIndex == 5 || selectedIndex == 6;

    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: TontiColors.white,
        border: Border(top: BorderSide(color: TontiColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, 0, 'Accueil', Icons.dashboard_outlined, Icons.dashboard),
          _buildNavItem(context, 1, 'Tontines', Icons.account_balance_outlined, Icons.account_balance),
          _buildNavItem(context, 2, 'Cotisations', Icons.payments_outlined, Icons.payments),
          // Bouton Plus (+) avec panneau accordéon
          InkWell(
            onTap: () => _showMoreModulesModal(context),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isMoreActive ? TontiColors.primaryGold : TontiColors.goldSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 20,
                      color: isMoreActive ? Colors.white : TontiColors.darkGold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Plus',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isMoreActive ? FontWeight.w800 : FontWeight.w500,
                      color: isMoreActive ? TontiColors.darkGold : TontiColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildNavItem(context, 7, 'Profil', Icons.person_outline, Icons.person),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String label, IconData icon, IconData activeIcon) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onDestinationSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected ? TontiColors.darkGold : TontiColors.textSecondary,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? TontiColors.darkGold : TontiColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
