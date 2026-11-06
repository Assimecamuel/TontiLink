import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/member_entity.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/tontine_controller.dart';
import '../../../widgets/common/tonti_button.dart';
import '../../../widgets/common/tonti_badge.dart';

class ManageMemberRoleDialog extends StatefulWidget {
  final String tontineId;
  final MemberEntity member;

  const ManageMemberRoleDialog({
    super.key,
    required this.tontineId,
    required this.member,
  });

  @override
  State<ManageMemberRoleDialog> createState() => _ManageMemberRoleDialogState();
}

class _ManageMemberRoleDialogState extends State<ManageMemberRoleDialog> {
  late MemberRole selectedRole;
  String statutoryReason = 'Décision statutaire de l\'Assemblée Générale';
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.member.role;
  }

  @override
  Widget build(BuildContext context) {
    final authController = AuthController();
    final isPresident = authController.isPresident;

    if (!isPresident) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.gpp_bad, color: AppColors.alertRed),
            SizedBox(width: 10),
            Text('Action non autorisée'),
          ],
        ),
        content: const Text(
          AppStrings.roleEditPresidentOnlyWarning,
          style: TextStyle(fontSize: 13.5, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Entête du Dialogue
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.goldSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: AppColors.primaryGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gouvernance de la Tontine', style: AppTypography.headingMedium),
                          const Text(
                            'Attribution statutaire de rôle par le Président',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              // Carte du membre concerné
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primaryGold,
                      child: Text(
                        widget.member.avatarInitials,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.member.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(widget.member.phone, style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Rôle actuel', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        TontiBadge(
                          label: widget.member.roleDisplayName,
                          variant: BadgeVariant.neutral,
                          isSmall: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Sélection du nouveau rôle
              Text('Attribuer un nouveau rôle statutaire :', style: AppTypography.headingSmall),
              const SizedBox(height: 10),

              _buildRoleChoice(
                role: MemberRole.president,
                title: 'Président(e)',
                desc: 'Direction générale, arbitrage et modification des rôles.',
                icon: Icons.shield,
              ),
              _buildRoleChoice(
                role: MemberRole.tresorier,
                title: 'Trésorier(e)',
                desc: 'Encaissement des cotisations, caisse commune et distributions.',
                icon: Icons.account_balance_wallet,
              ),
              _buildRoleChoice(
                role: MemberRole.secretaire,
                title: 'Secrétaire',
                desc: 'Tenue des registres, feuille d\'émargement et procès-verbaux.',
                icon: Icons.edit_document,
              ),
              _buildRoleChoice(
                role: MemberRole.commissaire,
                title: 'Commissaire aux comptes',
                desc: 'Contrôle et audit indépendant des flux financiers sans modification.',
                icon: Icons.fact_check,
              ),
              _buildRoleChoice(
                role: MemberRole.membre,
                title: 'Membre standard',
                desc: 'Participant cotisant avec droit de vote et de bénéfice.',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 16),

              // Motif statutaire
              TextFormField(
                initialValue: statutoryReason,
                decoration: const InputDecoration(
                  labelText: 'Motif ou référence de procès-verbal (PV)',
                  hintText: 'ex: Décision de l\'Assemblée Générale du 11 octobre',
                  prefixIcon: Icon(Icons.description_outlined, color: AppColors.primaryGold),
                ),
                onChanged: (val) => statutoryReason = val,
              ),
              const SizedBox(height: 16),

              // Avertissement de traçabilité
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.verified_user, color: AppColors.darkGold, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Traçabilité garantie : Cette nomination sera enregistrée sous la signature de ${authController.currentUser?.fullName} (Président) et inscrite dans le journal d\'audit de la tontine.',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.deepGold, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Boutons d'action
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TontiButton(
                    label: 'Annuler',
                    type: TontiButtonType.ghost,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  TontiButton(
                    label: 'Confirmer la nomination',
                    icon: Icons.check,
                    isLoading: isSubmitting,
                    onPressed: _submitRoleChange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChoice({
    required MemberRole role,
    required String title,
    required String desc,
    required IconData icon,
  }) {
    final isSelected = selectedRole == role;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? AppColors.goldSoft : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? AppColors.primaryGold : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: () => setState(() => selectedRole = role),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? AppColors.darkGold : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? AppColors.darkGold : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        desc,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Radio<MemberRole>(
                  value: role,
                  groupValue: selectedRole,
                  activeColor: AppColors.primaryGold,
                  onChanged: (val) => setState(() => selectedRole = val!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitRoleChange() async {
    setState(() => isSubmitting = true);

    final currentUser = AuthController().currentUser;
    if (currentUser == null) {
      setState(() => isSubmitting = false);
      return;
    }

    final success = await TontineController().changeMemberRole(
      tontineId: widget.tontineId,
      memberId: widget.member.id,
      newRole: selectedRole,
      performedByUser: currentUser,
      reason: statutoryReason,
    );

    setState(() => isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Le rôle de ${widget.member.fullName} a été mis à jour avec succès en tant que "${_getRoleName(selectedRole)}".',
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Le serveur a refusé la modification du rôle. Vérifiez vos droits et la connexion.',
          ),
          backgroundColor: AppColors.alertRed,
        ),
      );
    }
  }

  String _getRoleName(MemberRole role) {
    switch (role) {
      case MemberRole.president:
        return 'Président';
      case MemberRole.tresorier:
        return 'Trésorier';
      case MemberRole.secretaire:
        return 'Secrétaire';
      case MemberRole.commissaire:
        return 'Commissaire aux comptes';
      case MemberRole.membre:
        return 'Membre';
    }
  }
}
