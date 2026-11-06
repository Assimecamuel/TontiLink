/// Statut d'un tour de cotisation (contrat §1.9, champ `statutTour`).
enum TurnStatus {
  programmee, // PROGRAMMEE : cotisations en attente ou incomplètes
  preteADistribuer, // PRETE_A_DISTRIBUER : montantCollecte >= montantPrevu
  effectuee, // EFFECTUEE : cagnotte versée par le Trésorier
  confirmee, // CONFIRMEE : réception confirmée par le bénéficiaire
}

/// Tour de cotisation / ordre de passage d'un cycle
/// (`GET /api/tontines/cycles/<cycle_id>/ordre-passage/`).
class TurnEntity {
  final int id;
  final int cycleId;
  final int rank;
  final int adhesionId;
  final String memberName;
  final String phone;
  final DateTime? plannedDate;
  final double plannedAmount;
  final double collectedAmount;
  final TurnStatus status;
  final int? distributionId;
  final String distributionStatus;

  const TurnEntity({
    required this.id,
    required this.cycleId,
    required this.rank,
    required this.adhesionId,
    required this.memberName,
    this.phone = '',
    this.plannedDate,
    this.plannedAmount = 0,
    this.collectedAmount = 0,
    this.status = TurnStatus.programmee,
    this.distributionId,
    this.distributionStatus = '',
  });

  bool get isFinished =>
      status == TurnStatus.effectuee || status == TurnStatus.confirmee;

  double get progressRatio =>
      plannedAmount > 0 ? (collectedAmount / plannedAmount).clamp(0.0, 1.0) : 0.0;

  String get statusLabel {
    switch (status) {
      case TurnStatus.programmee:
        return 'Programmé';
      case TurnStatus.preteADistribuer:
        return 'Prêt à distribuer';
      case TurnStatus.effectuee:
        return 'Versé';
      case TurnStatus.confirmee:
        return 'Réception confirmée';
    }
  }
}
