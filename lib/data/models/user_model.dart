import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.phone,
    required super.email,
    required super.activeRole,
    super.isKycVerified = true,
    required super.avatarInitials,
    super.isOnline = false,
    super.isActive = true,
    super.lastSeen,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String? ?? '',
      activeRole: UserRole.values.firstWhere(
        (e) => e.name == json['activeRole'],
        orElse: () => UserRole.membre,
      ),
      isKycVerified: json['isKycVerified'] as bool? ?? true,
      avatarInitials: json['avatarInitials'] as String? ?? 'U',
      isOnline: json['isOnline'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      lastSeen: json['lastSeen'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'activeRole': activeRole.name,
      'isKycVerified': isKycVerified,
      'avatarInitials': avatarInitials,
      'isOnline': isOnline,
      'isActive': isActive,
      'lastSeen': lastSeen,
    };
  }
}
