enum LoanStatus {
  enAttente,
  approuve,
  enRemboursement,
  solde,
  rejete,
  enRetard,
}

class Loan {
  final String id;
  final String borrowerName;
  final String borrowerPhone;
  final double amountRequested;
  final String purpose;
  final double interestRatePercent;
  final int durationMonths;
  final double amountRepaid;
  final double remainingDue;
  final LoanStatus status;
  final DateTime requestDate;
  final DateTime? dueDate;
  final String? approvedByPresident;
  final String? approvedByTreasurer;

  const Loan({
    required this.id,
    required this.borrowerName,
    required this.borrowerPhone,
    required this.amountRequested,
    required this.purpose,
    required this.interestRatePercent,
    required this.durationMonths,
    required this.amountRepaid,
    required this.remainingDue,
    required this.status,
    required this.requestDate,
    this.dueDate,
    this.approvedByPresident,
    this.approvedByTreasurer,
  });

  String get statusLabel {
    switch (status) {
      case LoanStatus.enAttente:
        return 'En attente d\'approbation';
      case LoanStatus.approuve:
        return 'Approuvé (Déblocage)';
      case LoanStatus.enRemboursement:
        return 'En cours de remboursement';
      case LoanStatus.solde:
        return 'Totalement soldé';
      case LoanStatus.rejete:
        return 'Refusé';
      case LoanStatus.enRetard:
        return 'Échéance en retard';
    }
  }

  double get progressRatio =>
      amountRequested > 0 ? (amountRepaid / (amountRequested * (1 + interestRatePercent / 100))).clamp(0.0, 1.0) : 0.0;
}

enum AidEventType {
  deces,
  maladie,
  naissance,
  mariage,
  autreSecours,
}

enum AidEventStatus {
  soumis,
  valide,
  debourse,
  rejete,
}

class AidEvent {
  final String id;
  final String title;
  final String memberName;
  final AidEventType type;
  final double requestedAmount;
  final double approvedAmount;
  final AidEventStatus status;
  final DateTime date;
  final String justification;

  const AidEvent({
    required this.id,
    required this.title,
    required this.memberName,
    required this.type,
    required this.requestedAmount,
    required this.approvedAmount,
    required this.status,
    required this.date,
    required this.justification,
  });

  String get typeLabel {
    switch (type) {
      case AidEventType.deces:
        return 'Deuil / Obsèques';
      case AidEventType.maladie:
        return 'Assistance Maladie / Santé';
      case AidEventType.naissance:
        return 'Heureux Événement / Naissance';
      case AidEventType.mariage:
        return 'Mariage';
      case AidEventType.autreSecours:
        return 'Coup dur / Solidarité';
    }
  }
}

