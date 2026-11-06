enum TontineType {
  rotative,
  cumulative,
  avecPrets,
  entraide,
  projetCollectif,
}

enum TontineFrequency {
  hebdomadaire,
  bimensuelle,
  mensuelle,
}

enum TontineStatus {
  active,
  enPreparation,
  suspendue,
  cloturee,
}

enum DistributionMethod {
  ordrePredefini,
  tirageAuSort,
  personnalise,
}

class Tontine {
  final String id;
  final String name;
  final String description;
  final TontineType type;
  final TontineFrequency frequency;
  final TontineStatus status;
  final DistributionMethod distributionMethod;
  final double contributionAmount;
  final double totalCycleAmount;
  final int memberCount;
  final int maxMembers;
  final DateTime nextDueDate;
  final String nextBeneficiaryName;
  final String nextBeneficiaryAvatar;
  final int currentCycle;
  final int totalCycles;
  final double collectedAmountThisPeriod;
  final double cashReserveBalance;
  final bool isPrivate;
  final String coverTag;

  const Tontine({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.frequency,
    required this.status,
    required this.distributionMethod,
    required this.contributionAmount,
    required this.totalCycleAmount,
    required this.memberCount,
    required this.maxMembers,
    required this.nextDueDate,
    required this.nextBeneficiaryName,
    required this.nextBeneficiaryAvatar,
    required this.currentCycle,
    required this.totalCycles,
    required this.collectedAmountThisPeriod,
    required this.cashReserveBalance,
    this.isPrivate = true,
    this.coverTag = 'Or',
  });

  String get typeLabel {
    switch (type) {
      case TontineType.rotative:
        return 'Tontine Rotative';
      case TontineType.cumulative:
        return 'Tontine Cumulative';
      case TontineType.avecPrets:
        return 'Épargne & Prêts';
      case TontineType.entraide:
        return 'Fonds d\'Entraide';
      case TontineType.projetCollectif:
        return 'Projet Collectif';
    }
  }

  String get frequencyLabel {
    switch (frequency) {
      case TontineFrequency.hebdomadaire:
        return 'Hebdomadaire';
      case TontineFrequency.bimensuelle:
        return 'Bimensuelle';
      case TontineFrequency.mensuelle:
        return 'Mensuelle';
    }
  }

  double get progressRatio =>
      totalCycles > 0 ? (currentCycle / totalCycles).clamp(0.0, 1.0) : 0.0;
}

