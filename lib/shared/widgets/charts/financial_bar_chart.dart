import 'package:flutter/material.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/theme/tonti_typography.dart';
import '../../../core/utils/formatters.dart';

class MonthlyFinancialData {
  final String month;
  final double collected;
  final double expected;

  const MonthlyFinancialData({
    required this.month,
    required this.collected,
    required this.expected,
  });
}

class FinancialBarChart extends StatefulWidget {
  final List<MonthlyFinancialData> data;

  const FinancialBarChart({
    super.key,
    required this.data,
  });

  @override
  State<FinancialBarChart> createState() => _FinancialBarChartState();
}

class _FinancialBarChartState extends State<FinancialBarChart> {
  int? hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();

    // Trouver le montant maximum pour l'échelle
    double maxAmount = 100000;
    for (var item in widget.data) {
      final exp = item.expected.isNaN || item.expected.isInfinite ? 0.0 : item.expected;
      final coll = item.collected.isNaN || item.collected.isInfinite ? 0.0 : item.collected;
      if (exp > maxAmount) maxAmount = exp;
      if (coll > maxAmount) maxAmount = coll;
    }
    if (maxAmount <= 0) maxAmount = 100000;
    maxAmount = maxAmount * 1.15; // Marge haute

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Légende
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildLegendItem('Collecté (Réel)', TontiColors.primaryGold),
            const SizedBox(width: 16),
            _buildLegendItem('Prévu (Attendu)', TontiColors.border),
          ],
        ),
        const SizedBox(height: 16),
        // Graphique
        SizedBox(
          height: 200,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(widget.data.length, (index) {
                  final item = widget.data[index];
                  final isHovered = hoveredIndex == index;
                  final collected = item.collected.isNaN || item.collected.isInfinite ? 0.0 : item.collected;
                  final expected = item.expected.isNaN || item.expected.isInfinite ? 0.0 : item.expected;
                  
                  final collectedHeight = maxAmount > 0 ? (collected / maxAmount) * 160 : 0.0;
                  final expectedHeight = maxAmount > 0 ? (expected / maxAmount) * 160 : 0.0;
                  final percentage = expected > 0 ? ((collected / expected) * 100).toInt() : 0;

                  return MouseRegion(
                    onEnter: (_) => setState(() => hoveredIndex = index),
                    onExit: (_) => setState(() => hoveredIndex = null),
                    cursor: SystemMouseCursors.click,
                    child: Tooltip(
                      message:
                          '${item.month} :\nCollecté : ${Formatters.formatFCFA(collected)}\nAttendu : ${Formatters.formatFCFA(expected)}',
                      textStyle: const TextStyle(fontSize: 12, color: Colors.white),
                      decoration: BoxDecoration(
                        color: TontiColors.textPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isHovered)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '$percentage%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: TontiColors.primaryGold,
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 18),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Barre Collectée (Or)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: isHovered ? 16 : 14,
                                height: collectedHeight.clamp(4.0, 160.0),
                                decoration: BoxDecoration(
                                  color: isHovered
                                      ? TontiColors.darkGold
                                      : TontiColors.primaryGold,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Barre Prévue (Bordure / Gris clair)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: isHovered ? 16 : 14,
                                height: expectedHeight.clamp(4.0, 160.0),
                                decoration: BoxDecoration(
                                  color: TontiColors.border,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.month,
                            style: TontiTypography.bodySmall.copyWith(
                              fontWeight:
                                  isHovered ? FontWeight.w700 : FontWeight.w500,
                              color: isHovered
                                  ? TontiColors.primaryGold
                                  : TontiColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TontiTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

