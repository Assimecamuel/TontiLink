import '../entities/user_entity.dart';

abstract class AuthRepository {
  UserEntity? getCurrentUser();
  Future<UserEntity> login(String identifiant, String password);
  Future<Map<String, dynamic>> resendCode(String email);
  Future<UserEntity> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    UserRole initialRole = UserRole.membre,
    String intention = 'CREER_TONTINE',
    String? invitationCode,
  });
  Future<UserEntity> verifyRegistrationEmail(String email, String code);
  Future<bool> verifyOtp(String phone, String otp);
  void logout();
}
