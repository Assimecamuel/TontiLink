enum DistributionStatus {
  planifiee,
  enCollecte,
  validee,
  distribuee,
  litige,
}

class Distribution {
  final String id;
  final String tontineId;
  final String tontineName;
  final String beneficiaryName;
  final String beneficiaryPhone;
  final int turnNumber;
  final DateTime scheduledDate;
  final double theoreticalAmount;
  final double availableAmount;
  final double deductionFees;
  final double netAmount;
  final DistributionStatus status;
  final String? paymentReceiptUrl;
  final String? approvedByPresident;
  final String? approvedByTreasurer;

  const Distribution({
    required this.id,
    required this.tontineId,
    required this.tontineName,
    required this.beneficiaryName,
    required this.beneficiaryPhone,
    required this.turnNumber,
    required this.scheduledDate,
    required this.theoreticalAmount,
    required this.availableAmount,
    this.deductionFees = 0,
    required this.netAmount,
    required this.status,
    this.paymentReceiptUrl,
    this.approvedByPresident,
    this.approvedByTreasurer,
  });

  String get statusLabel {
    switch (status) {
      case DistributionStatus.planifiee:
        return 'Planifiée';
      case DistributionStatus.enCollecte:
        return 'En cours de collecte';
      case DistributionStatus.validee:
        return 'Validée & Prête';
      case DistributionStatus.distribuee:
        return 'Distribuée avec succès';
      case DistributionStatus.litige:
        return 'En attente de régularisation';
    }
  }

  bool get isFullyFunded => availableAmount >= theoreticalAmount;
}

