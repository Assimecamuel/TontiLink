import 'package:flutter/material.dart';
import '../../../core/theme/tonti_colors.dart';

class TontiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool hasGoldBorder;
  final Color? backgroundColor;
  final double borderRadius;

  const TontiCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.hasGoldBorder = false,
    this.backgroundColor,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final borderSide = hasGoldBorder
        ? const BorderSide(color: TontiColors.primaryGold, width: 1.5)
        : const BorderSide(color: TontiColors.border, width: 1);

    Widget content = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? TontiColors.cardBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.fromBorderSide(borderSide),
        boxShadow: [TontiColors.softShadow],
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          hoverColor: TontiColors.primaryGold.withOpacity(0.04),
          child: content,
        ),
      );
    }

    return content;
  }
}

