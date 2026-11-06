import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

class AuthController extends ChangeNotifier {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;

  final AuthRepository _authRepository = AuthRepositoryImpl();

  UserEntity? _currentUser;
  bool _isAuthenticated = false; // Par défaut non-connecté pour présenter la page de connexion
  bool _isLoading = false;
  String? _errorMessage;

  AuthController._internal() {
    _currentUser = _authRepository.getCurrentUser();
    // Démarre déconnecté pour laisser l'utilisateur voir la page de connexion
    _isAuthenticated = false;
  }

  UserEntity? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserRole get activeRole => _currentUser?.activeRole ?? UserRole.president;
  bool get isPresident => _currentUser?.isPresident ?? false;
  bool get isTreasurer => _currentUser?.isTreasurer ?? false;
  bool get isSecretary => _currentUser?.isSecretary ?? false;
  bool get isAuditor => _currentUser?.isAuditor ?? false;
  bool get isSimpleMember => _currentUser?.isSimpleMember ?? false;

  Future<bool> login(String identifiant, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.login(identifiant, password);
      _currentUser = user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    UserRole initialRole = UserRole.membre,
    String intention = 'CREER_TONTINE',
    String? invitationCode,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.register(
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
        initialRole: initialRole,
        intention: intention,
        invitationCode: invitationCode,
      );
      _currentUser = user;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyRegistrationEmail(String email, String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.verifyRegistrationEmail(email, code);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> resendCode(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.resendCode(email);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authRepository.verifyOtp(phone, otp);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
  void updateCurrentUser(UserEntity user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _authRepository.logout();
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }
}
