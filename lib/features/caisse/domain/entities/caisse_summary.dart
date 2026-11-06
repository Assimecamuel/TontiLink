enum CaisseCategory {
  cotisation,
  fondSecours,
  remboursementPret,
  fraisAdhesion,
  depenseFonctionnement,
  aideSociale,
  interetsPrets,
}

class CaisseEntry {
  final String id;
  final DateTime date;
  final String title;
  final CaisseCategory category;
  final double amount;
  final bool isCredit; // true = Entrée, false = Sortie
  final String performedBy;
  final bool isReconciled;
  final String proofReference;

  const CaisseEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.category,
    required this.amount,
    required this.isCredit,
    required this.performedBy,
    required this.isReconciled,
    required this.proofReference,
  });
}

class CaisseSummary {
  final double theoreticalBalance; // Solde comptable théorique
  final double availableCashBalance; // Espèces physiques en coffre
  final double mobileMoneyBalance; // Solde compte MTN / Orange
  final double bankBalance; // Solde bancaire
  final double totalIncome;
  final double totalExpense;
  final double pendingValidationAmount;
  final List<CaisseEntry> recentEntries;

  const CaisseSummary({
    required this.theoreticalBalance,
    required this.availableCashBalance,
    required this.mobileMoneyBalance,
    required this.bankBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.pendingValidationAmount,
    required this.recentEntries,
  });

  double get totalActualAvailable =>
      availableCashBalance + mobileMoneyBalance + bankBalance;
}

