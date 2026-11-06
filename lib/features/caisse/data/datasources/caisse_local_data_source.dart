import '../../domain/entities/caisse_summary.dart';

abstract class CaisseLocalDataSource {
  Future<CaisseSummary> getCaisseSummary();
}

/// Implémentation en mémoire (données de démonstration).
/// À remplacer par un appel API / base locale en production.
class CaisseLocalDataSourceImpl implements CaisseLocalDataSource {
  final CaisseSummary _caisseSummary = CaisseSummary(
    theoreticalBalance: 6150000,
    availableCashBalance: 1450000, // Espèces physiques coffre
    mobileMoneyBalance: 3200000, // Solde agrégé MTN / Orange
    bankBalance: 1500000, // Compte banque Afriland First Bank
    totalIncome: 14850000,
    totalExpense: 8700000,
    pendingValidationAmount: 125000,
    recentEntries: [
      CaisseEntry(
        id: 'c-1',
        date: DateTime.now().subtract(const Duration(hours: 3)),
        title: 'Cotisation Tour #7 - Paul Eric Kamdem',
        category: CaisseCategory.cotisation,
        amount: 100000,
        isCredit: true,
        performedBy: 'Automate MoMo',
        isReconciled: true,
        proofReference: 'REF-MOMO-889104',
      ),
      CaisseEntry(
        id: 'c-2',
        date: DateTime.now().subtract(const Duration(days: 1)),
        title: 'Versement espèces en réunion - Christian Mballa',
        category: CaisseCategory.cotisation,
        amount: 25000,
        isCredit: true,
        performedBy: 'Jeanne Ngo Bayi (Trésorière)',
        isReconciled: false,
        proofReference: 'REC-ESP-0089',
      ),
      CaisseEntry(
        id: 'c-3',
        date: DateTime.now().subtract(const Duration(days: 2)),
        title: 'Aide Solidarité Naissance - Clarisse Onana',
        category: CaisseCategory.aideSociale,
        amount: 75000,
        isCredit: false,
        performedBy: 'Double validation Comité',
        isReconciled: true,
        proofReference: 'PV-AID-2026-04',
      ),
      CaisseEntry(
        id: 'c-4',
        date: DateTime.now().subtract(const Duration(days: 4)),
        title: 'Frais location salle de réunion Akwa',
        category: CaisseCategory.depenseFonctionnement,
        amount: 15000,
        isCredit: false,
        performedBy: 'Samuel Eto\'o Talla',
        isReconciled: true,
        proofReference: 'FACTURE-SALLE-99',
      ),
    ],
  );

  @override
  Future<CaisseSummary> getCaisseSummary() async => _caisseSummary;

}
