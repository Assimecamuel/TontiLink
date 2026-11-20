import '../../domain/entities/member.dart';

abstract class MemberLocalDataSource {
  Future<List<Member>> getMembers();
}

/// Implémentation en mémoire (données de démonstration).
/// À remplacer par un appel API / base locale en production.
class MemberLocalDataSourceImpl implements MemberLocalDataSource {
  final List<Member> _members = [
    Member(
      id: 'mem-1',
      fullName: 'Paul Eric Kamdem',
      phone: '+237 677 45 89 12',
      email: 'p.kamdem@tontilink.cm',
      role: MemberRole.president,
      status: MemberStatus.actif,
      avatarInitials: 'PK',
      totalContributed: 700000,
      totalExpected: 700000,
      latePaymentsCount: 0,
      joinedDate: DateTime(2025, 1, 15),
      payoutTurn: 1,
    ),
    Member(
      id: 'mem-2',
      fullName: 'Jeanne Ngo Bayi',
      phone: '+237 699 12 34 56',
      email: 'j.ngobayi@gmail.com',
      role: MemberRole.tresorier,
      status: MemberStatus.actif,
      avatarInitials: 'JN',
      totalContributed: 700000,
      totalExpected: 700000,
      latePaymentsCount: 0,
      joinedDate: DateTime(2025, 1, 15),
      payoutTurn: 7,
    ),
    Member(
      id: 'mem-3',
      fullName: 'Samuel Eto\'o Talla',
      phone: '+237 655 78 90 23',
      email: 's.talla@yahoo.fr',
      role: MemberRole.secretaire,
      status: MemberStatus.actif,
      avatarInitials: 'ST',
      totalContributed: 700000,
      totalExpected: 700000,
      latePaymentsCount: 0,
      joinedDate: DateTime(2025, 1, 15),
      payoutTurn: 3,
    ),
    Member(
      id: 'mem-4',
      fullName: 'Christian Mballa',
      phone: '+237 670 98 12 43',
      email: 'c.mballa@outlook.com',
      role: MemberRole.commissaire,
      status: MemberStatus.actif,
      avatarInitials: 'CM',
      totalContributed: 650000,
      totalExpected: 700000,
      latePaymentsCount: 1,
      joinedDate: DateTime(2025, 1, 15),
      payoutTurn: 5,
    ),
    Member(
      id: 'mem-5',
      fullName: 'Béatrice Doumbé',
      phone: '+237 694 22 11 00',
      email: 'beatrice.d@gmail.com',
      role: MemberRole.membre,
      status: MemberStatus.actif,
      avatarInitials: 'BD',
      totalContributed: 700000,
      totalExpected: 700000,
      latePaymentsCount: 0,
      joinedDate: DateTime(2025, 1, 15),
      payoutTurn: 2,
    ),
    Member(
      id: 'mem-6',
      fullName: 'Hervé Tchinda',
      phone: '+237 672 33 44 55',
      email: 'h.tchinda@gmail.com',
      role: MemberRole.membre,
      status: MemberStatus.retard,
      avatarInitials: 'HT',
      totalContributed: 500000,
      totalExpected: 700000,
      latePaymentsCount: 2,
      joinedDate: DateTime(2025, 1, 15),
      payoutTurn: 11,
    ),
    Member(
      id: 'mem-7',
      fullName: 'Clarisse Onana',
      phone: '+237 690 11 22 88',
      email: 'clarisse.o@gmail.com',
      role: MemberRole.membre,
      status: MemberStatus.actif,
      avatarInitials: 'CO',
      totalContributed: 700000,
      totalExpected: 700000,
      latePaymentsCount: 0,
      joinedDate: DateTime(2025, 1, 15),
      payoutTurn: 8,
    ),
    Member(
      id: 'mem-8',
      fullName: 'Fabrice Mbarga',
      phone: '+237 651 88 77 66',
      email: 'f.mbarga@gmail.com',
      role: MemberRole.membre,
      status: MemberStatus.actif,
      avatarInitials: 'FM',
      totalContributed: 700000,
      totalExpected: 700000,
      latePaymentsCount: 0,
      joinedDate: DateTime(2025, 1, 15),
      payoutTurn: 4,
    ),
  ];

  @override
  Future<List<Member>> getMembers() async =>
      List<Member>.unmodifiable(_members);

}
