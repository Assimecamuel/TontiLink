enum UserRole {
  superAdmin,
  president,
  tresorier,
  secretaire,
  commissaire,
  membre,
}

class UserEntity {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final UserRole activeRole;
  final bool isKycVerified;
  final String avatarInitials;
  final bool isOnline;
  final bool isActive;
  final String? lastSeen;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.activeRole,
    this.isKycVerified = true,
    required this.avatarInitials,
    this.isOnline = false,
    this.isActive = true,
    this.lastSeen,
  });

  bool get isSuperAdmin => activeRole == UserRole.superAdmin;
  bool get isPresident => activeRole == UserRole.president;
  bool get isTreasurer => activeRole == UserRole.tresorier;
  bool get isSecretary => activeRole == UserRole.secretaire;
  bool get isAuditor => activeRole == UserRole.commissaire;
  bool get isSimpleMember => activeRole == UserRole.membre;

  String get roleDisplayName {
    switch (activeRole) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.president:
        return 'Président';
      case UserRole.tresorier:
        return 'Trésorier';
      case UserRole.secretaire:
        return 'Secrétaire';
      case UserRole.commissaire:
        return 'Commissaire aux comptes';
      case UserRole.membre:
        return 'Membre';
    }
  }

  UserEntity copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    UserRole? activeRole,
    bool? isKycVerified,
    String? avatarInitials,
    bool? isOnline,
    bool? isActive,
    String? lastSeen,
  }) {
    return UserEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      activeRole: activeRole ?? this.activeRole,
      isKycVerified: isKycVerified ?? this.isKycVerified,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      isOnline: isOnline ?? this.isOnline,
      isActive: isActive ?? this.isActive,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
