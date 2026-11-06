import '../../domain/entities/transaction.dart';

abstract class TransactionLocalDataSource {
  Future<List<Transaction>> getTransactions();
  Future<void> recordTransaction(Transaction item);
}

/// Implémentation en mémoire (données de démonstration).
/// À remplacer par un appel API / base locale en production.
class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final List<Transaction> _transactions = [
    Transaction(
      id: 'TXN-9842',
      tontineName: 'Tontine des Commerçants Mokolo',
      memberName: 'Paul Eric Kamdem',
      type: TransactionType.cotisation,
      amount: 100000,
      paymentMethod: PaymentMethod.mtnMoMo,
      status: TransactionStatus.confirme,
      date: DateTime.now().subtract(const Duration(hours: 3)),
      reference: 'MOMO-CMR-889104',
      validatedBy: 'Système API MTN',
      note: 'Cotisation Tour #7',
    ),
    Transaction(
      id: 'TXN-9841',
      tontineName: 'Tontine des Commerçants Mokolo',
      memberName: 'Béatrice Doumbé',
      type: TransactionType.cotisation,
      amount: 100000,
      paymentMethod: PaymentMethod.orangeMoney,
      status: TransactionStatus.confirme,
      date: DateTime.now().subtract(const Duration(hours: 6)),
      reference: 'OM-CMR-293817',
      validatedBy: 'Système API Orange',
      note: 'Cotisation Tour #7',
    ),
    Transaction(
      id: 'TXN-9840',
      tontineName: 'Solidarité Famille Manga',
      memberName: 'Christian Mballa',
      type: TransactionType.cotisation,
      amount: 25000,
      paymentMethod: PaymentMethod.especes,
      status: TransactionStatus.aVerifier,
      date: DateTime.now().subtract(const Duration(hours: 24)),
      reference: 'REC-ESP-0089',
      validatedBy: null,
      note: 'Espèces remis au Trésorier en réunion',
    ),
    Transaction(
      id: 'TXN-9839',
      tontineName: 'Club d\'Épargne & Crédit Akwa Tech',
      memberName: 'Alain Fotso',
      type: TransactionType.remboursement,
      amount: 85000,
      paymentMethod: PaymentMethod.virement,
      status: TransactionStatus.confirme,
      date: DateTime.now().subtract(const Duration(days: 2)),
      reference: 'VIR-AFRILAND-5541',
      validatedBy: 'Jeanne Ngo Bayi (Trésorière)',
      note: 'Échéance prêt mensuel #2',
    ),
    Transaction(
      id: 'TXN-9838',
      tontineName: 'Tontine des Commerçants Mokolo',
      memberName: 'Samuel Eto\'o Talla',
      type: TransactionType.distribution,
      amount: 1200000,
      paymentMethod: PaymentMethod.mtnMoMo,
      status: TransactionStatus.confirme,
      date: DateTime.now().subtract(const Duration(days: 14)),
      reference: 'MOMO-PAYOUT-3391',
      validatedBy: 'Double validation Trésorier & Président',
      note: 'Versement de la cagnotte Tour #6',
    ),
    Transaction(
      id: 'TXN-9837',
      tontineName: 'Tontine des Commerçants Mokolo',
      memberName: 'Hervé Tchinda',
      type: TransactionType.penalite,
      amount: 5000,
      paymentMethod: PaymentMethod.mtnMoMo,
      status: TransactionStatus.enAttente,
      date: DateTime.now().subtract(const Duration(days: 1)),
      reference: 'PEN-RET-091',
      validatedBy: null,
      note: 'Pénalité retard de versement (Article 12)',
    ),
  ];

  @override
  Future<List<Transaction>> getTransactions() async =>
      List<Transaction>.unmodifiable(_transactions);

  @override
  Future<void> recordTransaction(Transaction item) async {
    _transactions.insert(0, item);
  }

}
