import 'package:flutter/material.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';

enum BadgeVariant {
  success,
  warning,
  danger,
  info,
  gold,
  neutral,
}

class TontiBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final IconData? icon;
  final bool isSmall;

  const TontiBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.neutral,
    this.icon,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border;

    switch (variant) {
      case BadgeVariant.success:
        bg = TontiColors.successSoft;
        fg = TontiColors.successGreen;
        border = BorderSide(color: TontiColors.successGreen.withOpacity(0.2));
        break;
      case BadgeVariant.warning:
        bg = TontiColors.warningSoft;
        fg = TontiColors.warningOrange;
        border = BorderSide(color: TontiColors.warningOrange.withOpacity(0.2));
        break;
      case BadgeVariant.danger:
        bg = TontiColors.alertSoft;
        fg = TontiColors.alertRed;
        border = BorderSide(color: TontiColors.alertRed.withOpacity(0.2));
        break;
      case BadgeVariant.info:
        bg = TontiColors.infoSoft;
        fg = TontiColors.infoBlue;
        border = BorderSide(color: TontiColors.infoBlue.withOpacity(0.2));
        break;
      case BadgeVariant.gold:
        bg = TontiColors.goldSoft;
        fg = TontiColors.darkGold;
        border = const BorderSide(color: TontiColors.primaryGold, width: 0.8);
        break;
      case BadgeVariant.neutral:
        bg = TontiColors.surfaceMuted;
        fg = TontiColors.textSecondary;
        border = const BorderSide(color: TontiColors.border);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.fromBorderSide(border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isSmall ? 11 : 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TontiTypography.badgeText.copyWith(
              color: fg,
              fontSize: isSmall ? 10.5 : 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

