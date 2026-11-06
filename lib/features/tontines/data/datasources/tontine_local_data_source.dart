import '../../domain/entities/tontine.dart';

abstract class TontineLocalDataSource {
  Future<List<Tontine>> getTontines();
  Future<void> addTontine(Tontine item);
}

/// Implémentation en mémoire (données de démonstration).
/// À remplacer par un appel API / base locale en production.
class TontineLocalDataSourceImpl implements TontineLocalDataSource {
  final List<Tontine> _tontines = [
    Tontine(
      id: 'tontine-1',
      name: 'Tontine des Commerçants Mokolo',
      description: 'Groupe d\'entraide et d\'épargne rotative bimensuelle pour le développement commercial.',
      type: TontineType.rotative,
      frequency: TontineFrequency.bimensuelle,
      status: TontineStatus.active,
      distributionMethod: DistributionMethod.ordrePredefini,
      contributionAmount: 100000,
      totalCycleAmount: 1200000,
      memberCount: 12,
      maxMembers: 12,
      nextDueDate: DateTime.now().add(const Duration(days: 4)),
      nextBeneficiaryName: 'Mme Jeanne Ngo Bayi',
      nextBeneficiaryAvatar: 'JN',
      currentCycle: 7,
      totalCycles: 12,
      collectedAmountThisPeriod: 800000,
      cashReserveBalance: 250000,
      isPrivate: true,
      coverTag: 'Commerce',
    ),
    Tontine(
      id: 'tontine-2',
      name: 'Solidarité Famille Manga (Yaoundé)',
      description: 'Fonds d\'entraide familiale, assistance sociale, deuil et heureux événements.',
      type: TontineType.entraide,
      frequency: TontineFrequency.mensuelle,
      status: TontineStatus.active,
      distributionMethod: DistributionMethod.personnalise,
      contributionAmount: 25000,
      totalCycleAmount: 500000,
      memberCount: 20,
      maxMembers: 25,
      nextDueDate: DateTime.now().add(const Duration(days: 12)),
      nextBeneficiaryName: 'Caisse Secours Commun',
      nextBeneficiaryAvatar: 'CS',
      currentCycle: 10,
      totalCycles: 12,
      collectedAmountThisPeriod: 450000,
      cashReserveBalance: 1850000,
      isPrivate: true,
      coverTag: 'Famille',
    ),
    Tontine(
      id: 'tontine-3',
      name: 'Club d\'Épargne & Crédit Akwa Tech',
      description: 'Tontine moderne pour entrepreneurs et cadres avec caisse de micro-crédit à 2% d\'intérêts.',
      type: TontineType.avecPrets,
      frequency: TontineFrequency.mensuelle,
      status: TontineStatus.active,
      distributionMethod: DistributionMethod.tirageAuSort,
      contributionAmount: 250000,
      totalCycleAmount: 2500000,
      memberCount: 10,
      maxMembers: 10,
      nextDueDate: DateTime.now().add(const Duration(days: 8)),
      nextBeneficiaryName: 'Alain Fotso',
      nextBeneficiaryAvatar: 'AF',
      currentCycle: 4,
      totalCycles: 10,
      collectedAmountThisPeriod: 2250000,
      cashReserveBalance: 3450000,
      isPrivate: false,
      coverTag: 'Investissement',
    ),
    Tontine(
      id: 'tontine-4',
      name: 'Projet Agricole Obala 2026',
      description: 'Investissement collectif pour l\'acquisition et l\'exploitation d\'une plantation de manioc.',
      type: TontineType.projetCollectif,
      frequency: TontineFrequency.mensuelle,
      status: TontineStatus.enPreparation,
      distributionMethod: DistributionMethod.personnalise,
      contributionAmount: 150000,
      totalCycleAmount: 1800000,
      memberCount: 8,
      maxMembers: 12,
      nextDueDate: DateTime.now().add(const Duration(days: 18)),
      nextBeneficiaryName: 'Compte Projet Obala',
      nextBeneficiaryAvatar: 'PO',
      currentCycle: 1,
      totalCycles: 6,
      collectedAmountThisPeriod: 600000,
      cashReserveBalance: 600000,
      isPrivate: true,
      coverTag: 'Agriculture',
    ),
  ];

  @override
  Future<List<Tontine>> getTontines() async =>
      List<Tontine>.unmodifiable(_tontines);

  @override
  Future<void> addTontine(Tontine item) async {
    _tontines.insert(0, item);
  }

}
