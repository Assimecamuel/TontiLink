import '../../core/network/api_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_tonti_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalTontiDataSource _dataSource = LocalTontiDataSource();
  final ApiClient _api = ApiClient.instance;

  UserEntity? _pendingRegistrationUser;
  String _pendingIntention = 'CREER_TONTINE';

  String _formatPhone(String raw) {
    var clean = raw.replaceAll(RegExp(r'\s+'), '');
    if (!clean.startsWith('+')) {
      clean = clean.startsWith('237') ? '+$clean' : '+237$clean';
    }
    return clean;
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      value is Map<String, dynamic> ? value : const <String, dynamic>{};

  String? _readToken(Map<String, dynamic> data) {
    for (final key in ['token', 'access', 'access_token']) {
      final token = data[key];
      if (token is String && token.isNotEmpty) return token;
    }
    return null;
  }

  @override
  UserEntity? getCurrentUser() => _api.hasToken ? _dataSource.currentUser : null;

  @override
  Future<UserEntity> login(String identifiant, String password) async {
    final cleanIdentifiant = identifiant.contains('@')
        ? identifiant.trim()
        : _formatPhone(identifiant);

    final response = await _api.post('/api/comptes/auth/login/', {
      'identifiant': cleanIdentifiant,
      'motDePasse': password,
      'nomAppareil': 'TontiLink Flutter Client',
      'osAppareil': 'Flutter',
    });
    if (!response.isOk || response.data == null) {
      throw Exception(
        response.message ??
            'Connexion refusée par le serveur (HTTP ${response.statusCode}).',
      );
    }

    final responseData = _asMap(response.data);
    final token = _readToken(responseData);
    if (token == null) {
      throw Exception('Le serveur n’a pas fourni de jeton d’authentification.');
    }
    _dataSource.clearBusinessData();
    _api.setToken(token);

    final userData = _asMap(responseData['user']);
    final name = userData['nom']?.toString() ?? 'Utilisateur TontiLink';
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    final recommendedRole = userData['vue_recommandee']?.toString() ??
        userData['primary_role']?.toString() ??
        userData['roleGlobal']?.toString() ??
        'MEMBRE';
    final user = UserEntity(
      id: userData['id']?.toString() ?? '',
      fullName: name,
      phone: userData['telephone']?.toString() ?? cleanIdentifiant,
      email: userData['email']?.toString() ?? (cleanIdentifiant.contains('@') ? cleanIdentifiant : ''),
      activeRole: _mapRoleStringToEnum(recommendedRole),
      isKycVerified: true,
      avatarInitials: initials.isEmpty ? 'U' : initials,
    );
    _dataSource.currentUser = user;
    return user;
  }

  UserRole _mapRoleStringToEnum(String roleName) {
    switch (roleName.toUpperCase()) {
      case 'PRESIDENT':
      case 'FONDATEUR':
        return UserRole.president;
      case 'TRESORIER':
        return UserRole.tresorier;
      case 'SECRETAIRE':
        return UserRole.secretaire;
      case 'CONTROLEUR':
      case 'COMMISSAIRE':
        return UserRole.commissaire;
      default:
        return UserRole.membre;
    }
  }

  @override
  Future<UserEntity> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    UserRole initialRole = UserRole.membre,
    String intention = 'CREER_TONTINE',
    String? invitationCode,
  }) async {
    final formattedPhone = _formatPhone(phone);
    final isJoin = intention == 'REJOINDRE_TONTINE';
    final response = await _api.post('/api/comptes/auth/register/', {
      'nom': fullName,
      'telephone': formattedPhone,
      'email': email,
      'motDePasse': password,
      'langue': 'fr',
      'intention': isJoin ? 'REJOINDRE_TONTINE' : 'CREER_TONTINE',
      if (isJoin) 'codeInvitation': (invitationCode ?? '').trim(),
    });
    if (!response.isOk || response.data == null) {
      throw Exception(response.message ?? 'Inscription refusée par le serveur.');
    }

    final responseData = _asMap(response.data);
    final userData = _asMap(
      responseData.containsKey('user') && responseData['user'] is Map<String, dynamic>
          ? responseData['user']
          : responseData,
    );
    final serverName = userData['nom']?.toString() ?? fullName;
    final initials = serverName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    final user = UserEntity(
      id: userData['id']?.toString() ?? '',
      fullName: serverName,
      phone: userData['telephone']?.toString() ?? formattedPhone,
      email: userData['email']?.toString() ?? email,
      activeRole: isJoin ? UserRole.membre : UserRole.president,
      isKycVerified: false,
      avatarInitials: initials.isEmpty ? 'U' : initials,
    );
    _pendingIntention = isJoin ? 'REJOINDRE_TONTINE' : 'CREER_TONTINE';
    _dataSource.clearBusinessData();
    _dataSource.pendingTontineName = userData['tontine_nom']?.toString();
    _pendingRegistrationUser = user;
    _dataSource.currentUser = user;
    return user;
  }

  @override
  Future<UserEntity> verifyRegistrationEmail(String email, String code) async {
    final response = await _api.post(
      '/api/comptes/auth/register/verify-email/',
      {'email': email, 'code': code},
    );
    if (!response.isOk || response.data == null) {
      throw Exception(response.message ?? 'Vérification de l’e-mail échouée.');
    }
    final responseData = _asMap(response.data);
    final token = _readToken(responseData);
    if (token == null) {
      throw Exception('Le serveur n’a pas fourni de jeton d’authentification.');
    }
    _api.setToken(token);

    final userData = _asMap(
      responseData.containsKey('user') && responseData['user'] is Map<String, dynamic>
          ? responseData['user']
          : responseData,
    );

    final pendingUser = _pendingRegistrationUser;
    final name = userData['nom']?.toString() ?? pendingUser?.fullName ?? 'Utilisateur TontiLink';
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    final user = UserEntity(
      id: userData['id']?.toString() ?? pendingUser?.id ?? '1',
      fullName: name,
      phone: userData['telephone']?.toString() ?? pendingUser?.phone ?? '',
      email: userData['email']?.toString() ?? email,
      activeRole: _pendingIntention == 'REJOINDRE_TONTINE'
          ? UserRole.membre
          : UserRole.president,
      isKycVerified: true,
      avatarInitials: initials.isEmpty ? 'U' : initials,
    );
    _dataSource.currentUser = user;
    _pendingRegistrationUser = null;
    return user;
  }

  @override
  Future<Map<String, dynamic>> resendCode(String email) async {
    final response = await _api.post('/api/comptes/auth/register/resend-code/', {
      'email': email.trim(),
    });
    if (!response.isOk || response.data == null) {
      throw Exception(response.message ?? 'Échec lors du renvoi du code.');
    }
    return _asMap(response.data);
  }

  @override
  Future<bool> verifyOtp(String phone, String otp) async {
    final response = await _api.post('/api/comptes/auth/otp/verify/', {
      'telephone': _formatPhone(phone),
      'code': otp,
      'objectif': 'CONNEXION',
    });
    return response.isOk;
  }

  @override
  void logout() {
    _api.clearToken();
    _dataSource.clearBusinessData();
    _pendingRegistrationUser = null;
  }
}
