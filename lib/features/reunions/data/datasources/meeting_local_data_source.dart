import '../../domain/entities/meeting.dart';

abstract class MeetingLocalDataSource {
  Future<List<Meeting>> getMeetings();
}

/// Implémentation en mémoire (données de démonstration).
/// À remplacer par un appel API / base locale en production.
class MeetingLocalDataSourceImpl implements MeetingLocalDataSource {
  final List<Meeting> _meetings = [
    Meeting(
      id: 'MEET-08',
      tontineId: 'tontine-1',
      tontineName: 'Tontine des Commerçants Mokolo',
      title: 'Grande Réunion Mensuelle & Tour #7',
      dateTime: DateTime.now().add(const Duration(days: 4, hours: 2)),
      location: 'Chez Papa Kamdem, Rue Koumassi, Douala',
      hostName: 'Paul Eric Kamdem',
      status: MeetingStatus.aVenir,
      attendeesCount: 0,
      totalExpectedMembers: 12,
      totalCashCollected: 0,
      minutesSummary: 'Ordre du jour : Cotisations du tour #7, remise de la cagnotte à Mme Ngo Bayi, examen de la demande de prêt de M. Tchinda.',
      attendanceList: [
        MeetingAttendanceItem(memberId: 'mem-1', memberName: 'Paul Eric Kamdem', isPresent: true, cashContributed: 0, note: 'Payé via MoMo'),
        MeetingAttendanceItem(memberId: 'mem-2', memberName: 'Jeanne Ngo Bayi', isPresent: true, cashContributed: 0, note: 'Bénéficiaire du tour'),
        MeetingAttendanceItem(memberId: 'mem-3', memberName: 'Samuel Eto\'o Talla', isPresent: false, cashContributed: 0),
        MeetingAttendanceItem(memberId: 'mem-4', memberName: 'Christian Mballa', isPresent: false, cashContributed: 0),
        MeetingAttendanceItem(memberId: 'mem-5', memberName: 'Béatrice Doumbé', isPresent: false, cashContributed: 0),
        MeetingAttendanceItem(memberId: 'mem-6', memberName: 'Hervé Tchinda', isPresent: false, cashContributed: 0),
      ],
    ),
    Meeting(
      id: 'MEET-07',
      tontineId: 'tontine-1',
      tontineName: 'Tontine des Commerçants Mokolo',
      title: 'Réunion du Tour #6 & Bilan mi-parcours',
      dateTime: DateTime.now().subtract(const Duration(days: 14)),
      location: 'Foyer des Commerçants, Mokolo, Yaoundé',
      hostName: 'Jeanne Ngo Bayi',
      status: MeetingStatus.cloturee,
      attendeesCount: 11,
      totalExpectedMembers: 12,
      totalCashCollected: 400000,
      minutesSummary: 'Tous les membres présents sauf M. Tchinda (excusé). 400 000 FCFA collectés en cash, le reste via Mobile Money. Tour #6 remis à M. Talla après double validation.',
      attendanceList: [],
    ),
  ];

  @override
  Future<List<Meeting>> getMeetings() async =>
      List<Meeting>.unmodifiable(_meetings);

}
