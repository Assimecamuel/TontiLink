import 'package:flutter/material.dart';
import '../../../core/theme/public_palette.dart';
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
    final p = Pal.of(context);
    final borderSide = hasGoldBorder
        ? BorderSide(color: p.gold, width: 1.5)
        : BorderSide(color: p.border, width: 1);

    Widget content = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? p.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.fromBorderSide(borderSide),
        boxShadow: [
          BoxShadow(
            color: p.dark
                ? Colors.black.withOpacity(0.3)
                : TontiColors.textPrimary.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
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
          hoverColor: p.gold.withOpacity(0.06),
          child: content,
        ),
      );
    }

    return content;
  }
}

