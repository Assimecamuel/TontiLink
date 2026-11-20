enum MemberRole {
  president,
  tresorier,
  secretaire,
  commissaire,
  membre,
}

enum MemberStatus {
  actif,
  retard,
  invite,
  suspendu,
}

class Member {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final MemberRole role;
  final MemberStatus status;
  final String avatarInitials;
  final double totalContributed;
  final double totalExpected;
  final int latePaymentsCount;
  final DateTime joinedDate;
  final int payoutTurn;

  const Member({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email = '',
    required this.role,
    required this.status,
    required this.avatarInitials,
    required this.totalContributed,
    required this.totalExpected,
    this.latePaymentsCount = 0,
    required this.joinedDate,
    required this.payoutTurn,
  });

  String get roleLabel {
    switch (role) {
      case MemberRole.president:
        return 'Président';
      case MemberRole.tresorier:
        return 'Trésorier';
      case MemberRole.secretaire:
        return 'Secrétaire';
      case MemberRole.commissaire:
        return 'Commissaire aux comptes';
      case MemberRole.membre:
        return 'Membre';
    }
  }

  bool get isUpToDate => totalContributed >= totalExpected;
}

