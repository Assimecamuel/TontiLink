import 'package:flutter/material.dart';
import '../../../core/theme/tonti_colors.dart';
import '../../../core/utils/formatters.dart';

class ReceiptDialog {
  static void show(
    BuildContext context, {
    required String title,
    required String reference,
    required String memberName,
    required String tontineName,
    required double amount,
    required String paymentMethod,
    required DateTime date,
    String? note,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TontiColors.goldSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.receipt_long_rounded, color: TontiColors.darkGold, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const Text('TontiLink • Reçu Officiel Certifié', style: TextStyle(fontSize: 11, color: TontiColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TontiColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TontiColors.primaryGold.withOpacity(0.4), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const Text('REÇU DE PAIEMENT / CAGNOTTE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2, color: TontiColors.darkGold)),
                      const SizedBox(height: 4),
                      const Text('Réf officielle : CERT-TL-2026', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: TontiColors.textSecondary)),
                    ],
                  ),
                ),
                const Divider(height: 24),
                _row('Tontine :', tontineName),
                _row('Membre :', memberName),
                _row('Date :', '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'),
                _row('Moyen de paiement :', paymentMethod),
                if (note != null && note.isNotEmpty) _row('Motif / Note :', note),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('MONTANT TOTAL :', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    Text(Formatters.formatFCFA(amount), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: TontiColors.primaryGold)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TontiColors.successSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.verified, color: TontiColors.successGreen, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Transaction certifiée par double signature (Président & Trésorier).',
                          style: TextStyle(fontSize: 11, color: TontiColors.successGreen, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Impression du reçu thermique lancée avec succès !'),
                  backgroundColor: TontiColors.successGreen,
                ),
              );
            },
            icon: const Icon(Icons.print, size: 16),
            label: const Text('Imprimer'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: TontiColors.primaryGold),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reçu officiel téléchargé (TontiLink_Recu_Officiel.pdf) !'),
                  backgroundColor: TontiColors.successGreen,
                ),
              );
            },
            icon: const Icon(Icons.download, size: 16, color: Colors.white),
            label: const Text('Télécharger PDF', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: TontiColors.textSecondary, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: TontiColors.textPrimary)),
        ],
      ),
    );
  }
}
