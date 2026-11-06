import 'package:flutter/material.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';

enum TontiButtonType {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
}

class TontiButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TontiButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;

  const TontiButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = TontiButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 46,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border;

    switch (type) {
      case TontiButtonType.primary:
        bg = TontiColors.primaryGold;
        fg = TontiColors.white;
        border = BorderSide.none;
        break;
      case TontiButtonType.secondary:
        bg = TontiColors.goldSoft;
        fg = TontiColors.darkGold;
        border = BorderSide.none;
        break;
      case TontiButtonType.outline:
        bg = Colors.transparent;
        fg = TontiColors.textPrimary;
        border = const BorderSide(color: TontiColors.border, width: 1.5);
        break;
      case TontiButtonType.ghost:
        bg = Colors.transparent;
        fg = TontiColors.textPrimary;
        border = BorderSide.none;
        break;
      case TontiButtonType.destructive:
        bg = TontiColors.alertRed;
        fg = TontiColors.white;
        border = BorderSide.none;
        break;
    }

    final buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TontiTypography.buttonText.copyWith(color: fg),
          ),
        ],
      ],
    );

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: Material(
        color: onPressed == null ? bg.withOpacity(0.5) : bg,
        shape: border != BorderSide.none
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: border,
              )
            : RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: (isLoading || onPressed == null) ? null : onPressed,
          borderRadius: BorderRadius.circular(10),
          hoverColor: TontiColors.primaryGold.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: buttonChild,
          ),
        ),
      ),
    );
  }
}

