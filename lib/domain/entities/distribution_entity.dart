enum DistributionStatus {
  planifiee,
  enCollecte,
  validee,
  distribuee,
  litige,
}

class DistributionEntity {
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

  const DistributionEntity({
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

  DistributionEntity copyWith({
    String? id,
    String? tontineId,
    String? tontineName,
    String? beneficiaryName,
    String? beneficiaryPhone,
    int? turnNumber,
    DateTime? scheduledDate,
    double? theoreticalAmount,
    double? availableAmount,
    double? deductionFees,
    double? netAmount,
    DistributionStatus? status,
    String? paymentReceiptUrl,
    String? approvedByPresident,
    String? approvedByTreasurer,
  }) {
    return DistributionEntity(
      id: id ?? this.id,
      tontineId: tontineId ?? this.tontineId,
      tontineName: tontineName ?? this.tontineName,
      beneficiaryName: beneficiaryName ?? this.beneficiaryName,
      beneficiaryPhone: beneficiaryPhone ?? this.beneficiaryPhone,
      turnNumber: turnNumber ?? this.turnNumber,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      theoreticalAmount: theoreticalAmount ?? this.theoreticalAmount,
      availableAmount: availableAmount ?? this.availableAmount,
      deductionFees: deductionFees ?? this.deductionFees,
      netAmount: netAmount ?? this.netAmount,
      status: status ?? this.status,
      paymentReceiptUrl: paymentReceiptUrl ?? this.paymentReceiptUrl,
      approvedByPresident: approvedByPresident ?? this.approvedByPresident,
      approvedByTreasurer: approvedByTreasurer ?? this.approvedByTreasurer,
    );
  }
}
