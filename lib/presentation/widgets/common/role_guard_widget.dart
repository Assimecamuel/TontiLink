import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/user_entity.dart';
import '../../controllers/auth_controller.dart';
import 'tonti_badge.dart';

class RoleGuardWidget extends StatelessWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;
  final String lockExplanation;

  const RoleGuardWidget({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
    this.lockExplanation = 'Action réservée au Président de la tontine',
  });

  @override
  Widget build(BuildContext context) {
    final activeRole = AuthController().activeRole;
    final isAllowed = allowedRoles.contains(activeRole);

    if (isAllowed) {
      return child;
    }

    if (fallback != null) {
      return fallback!;
    }

    // Affichage par défaut si non autorisé : indicateur de restriction statutaire élégant
    return Tooltip(
      message: lockExplanation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              'Réservé au Président',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
