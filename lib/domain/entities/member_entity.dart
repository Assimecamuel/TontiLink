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

class MemberEntity {
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
  final String roleAssignedBy; // Traçabilité : Nom du Président ayant attribué le rôle
  final DateTime? roleAssignedDate;

  /// `statutCotisation` du backend : `A_JOUR` ou `EN_RETARD` (échéances échues
  /// uniquement). Vide si le backend ne l'a pas renvoyé.
  final String contributionStatus;

  /// `peutCotiser` : false tant que des pénalités restent impayées.
  final bool canContribute;
  final int unpaidPenaltiesCount;
  final double unpaidPenaltiesAmount;

  const MemberEntity({
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
    this.roleAssignedBy = '',
    this.roleAssignedDate,
    this.contributionStatus = '',
    this.canContribute = true,
    this.unpaidPenaltiesCount = 0,
    this.unpaidPenaltiesAmount = 0,
  });

  String get roleDisplayName {
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

  /// Alias utilisé par les écrans (libellé du rôle)
  String get roleLabel => roleDisplayName;

  /// À jour = aucune échéance échue impayée (`statutCotisation`). Sans cette
  /// info, repli sur la comparaison des totaux.
  bool get isUpToDate => contributionStatus.isNotEmpty
      ? contributionStatus == 'A_JOUR'
      : totalContributed >= totalExpected;

  MemberEntity copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    MemberRole? role,
    MemberStatus? status,
    String? avatarInitials,
    double? totalContributed,
    double? totalExpected,
    int? latePaymentsCount,
    DateTime? joinedDate,
    int? payoutTurn,
    String? roleAssignedBy,
    DateTime? roleAssignedDate,
    String? contributionStatus,
    bool? canContribute,
    int? unpaidPenaltiesCount,
    double? unpaidPenaltiesAmount,
  }) {
    return MemberEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      totalContributed: totalContributed ?? this.totalContributed,
      totalExpected: totalExpected ?? this.totalExpected,
      latePaymentsCount: latePaymentsCount ?? this.latePaymentsCount,
      joinedDate: joinedDate ?? this.joinedDate,
      payoutTurn: payoutTurn ?? this.payoutTurn,
      roleAssignedBy: roleAssignedBy ?? this.roleAssignedBy,
      roleAssignedDate: roleAssignedDate ?? this.roleAssignedDate,
      contributionStatus: contributionStatus ?? this.contributionStatus,
      canContribute: canContribute ?? this.canContribute,
      unpaidPenaltiesCount: unpaidPenaltiesCount ?? this.unpaidPenaltiesCount,
      unpaidPenaltiesAmount:
          unpaidPenaltiesAmount ?? this.unpaidPenaltiesAmount,
    );
  }
}
