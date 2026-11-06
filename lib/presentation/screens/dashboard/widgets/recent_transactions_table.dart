import 'package:flutter/material.dart';
import '../../../../core/theme/tonti_colors.dart';
import '../../../../core/theme/tonti_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../models/transaction_model.dart';
import '../../../widgets/common/tonti_badge.dart';

class RecentTransactionsTable extends StatelessWidget {
  final List<TransactionModel> transactions;
  final ValueChanged<TransactionModel> onTransactionSelected;

  const RecentTransactionsTable({
    super.key,
    required this.transactions,
    required this.onTransactionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    if (!isDesktop) {
      // Vue Mobile : Liste de cartes compactes
      return Column(
        children: transactions.map((txn) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: TontiColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: TontiColors.border),
              ),
              child: InkWell(
                onTap: () => onTransactionSelected(txn),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      _buildPaymentIcon(txn.paymentMethod),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              txn.memberName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${txn.typeLabel} • ${txn.reference}',
                              style: TontiTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.formatFCFA(txn.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: TontiColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildStatusBadge(txn.status),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    // Vue Desktop : Tableau clair avec colonnes
    return Container(
      decoration: BoxDecoration(
        color: TontiColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TontiColors.border),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2), // Réf
          1: FlexColumnWidth(1.5), // Membre
          2: FlexColumnWidth(1.5), // Opération
          3: FlexColumnWidth(1.4), // Montant
          4: FlexColumnWidth(1.4), // Mode
          5: FlexColumnWidth(1.2), // Statut
          6: FixedColumnWidth(60), // Action
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Entête
          TableRow(
            decoration: const BoxDecoration(
              color: TontiColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            children: [
              _buildHeaderCell('RÉFÉRENCE'),
              _buildHeaderCell('MEMBRE'),
              _buildHeaderCell('OPÉRATION'),
              _buildHeaderCell('MONTANT'),
              _buildHeaderCell('MOYEN DE PAIEMENT'),
              _buildHeaderCell('STATUT'),
              _buildHeaderCell('ACTION'),
            ],
          ),
          // Lignes
          ...transactions.map((txn) {
            return TableRow(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: TontiColors.divider)),
              ),
              children: [
                _buildDataCell(
                  Text(
                    txn.reference,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: TontiColors.darkGold,
                    ),
                  ),
                ),
                _buildDataCell(
                  Text(
                    txn.memberName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildDataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn.typeLabel,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        txn.tontineName,
                        style: TontiTypography.bodySmall.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildDataCell(
                  Text(
                    Formatters.formatFCFA(txn.amount),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: TontiColors.textPrimary,
                    ),
                  ),
                ),
                _buildDataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPaymentIcon(txn.paymentMethod, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        txn.paymentMethodLabel,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildDataCell(_buildStatusBadge(txn.status)),
                _buildDataCell(
                  IconButton(
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                    color: TontiColors.textSecondary,
                    onPressed: () => onTransactionSelected(txn),
                    tooltip: 'Détails du reçu',
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: TontiColors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDataCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: child,
    );
  }

  Widget _buildPaymentIcon(PaymentMethod method, {double size = 32}) {
    Color bg;
    IconData icon;
    Color fg;

    switch (method) {
      case PaymentMethod.mtnMoMo:
        bg = const Color(0xFFFFF7D6);
        fg = const Color(0xFFB38600);
        icon = Icons.phone_android;
        break;
      case PaymentMethod.orangeMoney:
        bg = const Color(0xFFFFECE0);
        fg = const Color(0xFFCC5200);
        icon = Icons.mobile_friendly;
        break;
      case PaymentMethod.especes:
        bg = TontiColors.successSoft;
        fg = TontiColors.successGreen;
        icon = Icons.attach_money;
        break;
      case PaymentMethod.virement:
        bg = TontiColors.infoSoft;
        fg = TontiColors.infoBlue;
        icon = Icons.account_balance;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Icon(icon, size: size * 0.55, color: fg),
    );
  }

  Widget _buildStatusBadge(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.confirme:
        return const TontiBadge(label: 'Confirmé', variant: BadgeVariant.success, isSmall: true);
      case TransactionStatus.enAttente:
        return const TontiBadge(label: 'En attente', variant: BadgeVariant.warning, isSmall: true);
      case TransactionStatus.aVerifier:
        return const TontiBadge(label: 'À vérifier', variant: BadgeVariant.info, isSmall: true);
      case TransactionStatus.echoue:
        return const TontiBadge(label: 'Échoué', variant: BadgeVariant.danger, isSmall: true);
      case TransactionStatus.annule:
        return const TontiBadge(label: 'Annulé', variant: BadgeVariant.neutral, isSmall: true);
    }
  }
}

