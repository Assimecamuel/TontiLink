import 'member_entity.dart';

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

class TontineEntity {
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
  final List<MemberEntity> members;

  const TontineEntity({
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
    this.members = const [],
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

  TontineEntity copyWith({
    String? id,
    String? name,
    String? description,
    TontineType? type,
    TontineFrequency? frequency,
    TontineStatus? status,
    DistributionMethod? distributionMethod,
    double? contributionAmount,
    double? totalCycleAmount,
    int? memberCount,
    int? maxMembers,
    DateTime? nextDueDate,
    String? nextBeneficiaryName,
    String? nextBeneficiaryAvatar,
    int? currentCycle,
    int? totalCycles,
    double? collectedAmountThisPeriod,
    double? cashReserveBalance,
    bool? isPrivate,
    String? coverTag,
    List<MemberEntity>? members,
  }) {
    return TontineEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      status: status ?? this.status,
      distributionMethod: distributionMethod ?? this.distributionMethod,
      contributionAmount: contributionAmount ?? this.contributionAmount,
      totalCycleAmount: totalCycleAmount ?? this.totalCycleAmount,
      memberCount: memberCount ?? this.memberCount,
      maxMembers: maxMembers ?? this.maxMembers,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      nextBeneficiaryName: nextBeneficiaryName ?? this.nextBeneficiaryName,
      nextBeneficiaryAvatar: nextBeneficiaryAvatar ?? this.nextBeneficiaryAvatar,
      currentCycle: currentCycle ?? this.currentCycle,
      totalCycles: totalCycles ?? this.totalCycles,
      collectedAmountThisPeriod: collectedAmountThisPeriod ?? this.collectedAmountThisPeriod,
      cashReserveBalance: cashReserveBalance ?? this.cashReserveBalance,
      isPrivate: isPrivate ?? this.isPrivate,
      coverTag: coverTag ?? this.coverTag,
      members: members ?? this.members,
    );
  }
}
