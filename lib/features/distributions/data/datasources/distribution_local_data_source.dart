import '../../domain/entities/distribution.dart';

abstract class DistributionLocalDataSource {
  Future<List<Distribution>> getDistributions();
}

/// Implémentation en mémoire (données de démonstration).
/// À remplacer par un appel API / base locale en production.
class DistributionLocalDataSourceImpl implements DistributionLocalDataSource {
  final List<Distribution> _distributions = [
    Distribution(
      id: 'dist-7',
      tontineId: 'tontine-1',
      tontineName: 'Tontine des Commerçants Mokolo',
      beneficiaryName: 'Mme Jeanne Ngo Bayi',
      beneficiaryPhone: '+237 699 12 34 56',
      turnNumber: 7,
      scheduledDate: DateTime.now().add(const Duration(days: 4)),
      theoreticalAmount: 1200000,
      availableAmount: 800000,
      deductionFees: 0,
      netAmount: 1200000,
      status: DistributionStatus.enCollecte,
      approvedByPresident: 'Paul Eric Kamdem',
      approvedByTreasurer: null,
    ),
    Distribution(
      id: 'dist-8',
      tontineId: 'tontine-1',
      tontineName: 'Tontine des Commerçants Mokolo',
      beneficiaryName: 'Clarisse Onana',
      beneficiaryPhone: '+237 690 11 22 88',
      turnNumber: 8,
      scheduledDate: DateTime.now().add(const Duration(days: 18)),
      theoreticalAmount: 1200000,
      availableAmount: 0,
      deductionFees: 0,
      netAmount: 1200000,
      status: DistributionStatus.planifiee,
    ),
    Distribution(
      id: 'dist-6',
      tontineId: 'tontine-1',
      tontineName: 'Tontine des Commerçants Mokolo',
      beneficiaryName: 'Samuel Eto\'o Talla',
      beneficiaryPhone: '+237 655 78 90 23',
      turnNumber: 6,
      scheduledDate: DateTime.now().subtract(const Duration(days: 14)),
      theoreticalAmount: 1200000,
      availableAmount: 1200000,
      deductionFees: 0,
      netAmount: 1200000,
      status: DistributionStatus.distribuee,
      paymentReceiptUrl: 'https://tontilink.cm/receipts/rec-dist-06.pdf',
      approvedByPresident: 'Paul Eric Kamdem',
      approvedByTreasurer: 'Jeanne Ngo Bayi',
    ),
  ];

  @override
  Future<List<Distribution>> getDistributions() async =>
      List<Distribution>.unmodifiable(_distributions);

}
