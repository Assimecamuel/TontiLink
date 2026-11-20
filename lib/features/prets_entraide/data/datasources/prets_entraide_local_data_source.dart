import '../../domain/entities/loan_and_aid.dart';

abstract class PretsEntraideLocalDataSource {
  Future<List<Loan>> getLoans();
  Future<List<AidEvent>> getAidEvents();
}

/// Implémentation en mémoire (données de démonstration).
/// À remplacer par un appel API / base locale en production.
class PretsEntraideLocalDataSourceImpl implements PretsEntraideLocalDataSource {
  final List<Loan> _loans = [
    Loan(
      id: 'LOAN-102',
      borrowerName: 'Alain Fotso',
      borrowerPhone: '+237 677 88 99 00',
      amountRequested: 500000,
      purpose: 'Achat de stock fournitures de bureau',
      interestRatePercent: 2.0,
      durationMonths: 6,
      amountRepaid: 255000,
      remainingDue: 255000,
      status: LoanStatus.enRemboursement,
      requestDate: DateTime.now().subtract(const Duration(days: 60)),
      dueDate: DateTime.now().add(const Duration(days: 120)),
      approvedByPresident: 'Paul Eric Kamdem',
      approvedByTreasurer: 'Jeanne Ngo Bayi',
    ),
    Loan(
      id: 'LOAN-103',
      borrowerName: 'Hervé Tchinda',
      borrowerPhone: '+237 672 33 44 55',
      amountRequested: 300000,
      purpose: 'Réparation équipement frigorifique magasin',
      interestRatePercent: 2.0,
      durationMonths: 3,
      amountRepaid: 0,
      remainingDue: 306000,
      status: LoanStatus.enAttente,
      requestDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final List<AidEvent> _aidEvents = [
    AidEvent(
      id: 'AID-01',
      title: 'Assistance Maternité',
      memberName: 'Clarisse Onana',
      type: AidEventType.naissance,
      requestedAmount: 75000,
      approvedAmount: 75000,
      status: AidEventStatus.debourse,
      date: DateTime.now().subtract(const Duration(days: 3)),
      justification: 'Certificat de naissance du 08/10/2026 présenté au bureau',
    ),
    AidEvent(
      id: 'AID-02',
      title: 'Obsèques beau-père',
      memberName: 'Fabrice Mbarga',
      type: AidEventType.deces,
      requestedAmount: 150000,
      approvedAmount: 150000,
      status: AidEventStatus.valide,
      date: DateTime.now().subtract(const Duration(days: 1)),
      justification: 'Faire-part et lettre officielle de notification',
    ),
  ];

  @override
  Future<List<Loan>> getLoans() async =>
      List<Loan>.unmodifiable(_loans);

  @override
  Future<List<AidEvent>> getAidEvents() async =>
      List<AidEvent>.unmodifiable(_aidEvents);

}
