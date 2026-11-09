import '../../domain/entities/user_entity.dart';
import '../../domain/entities/tontine_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/distribution_entity.dart';
import '../../domain/entities/caisse_entity.dart';
import '../../domain/entities/loan_and_aid_entity.dart';
import '../../domain/entities/meeting_entity.dart';
import '../../domain/entities/turn_entity.dart';
import '../../core/network/api_client.dart';

class LocalTontiDataSource {
  static final LocalTontiDataSource _instance = LocalTontiDataSource._internal();
  factory LocalTontiDataSource() => _instance;

  LocalTontiDataSource._internal() {
    // Aucune donnée par défaut : tout provient de la base (API Django).
    clearBusinessData();
  }

  /// Utilisateur connecté (renseigné par la connexion / l'inscription).
  UserEntity currentUser = const UserEntity(
    id: '',
    fullName: '',
    phone: '',
    email: '',
    activeRole: UserRole.membre,
    isKycVerified: false,
    avatarInitials: '',
  );
  late List<TontineEntity> tontines;
  late List<MemberEntity> members;
  late List<TransactionEntity> transactions;
  late List<DistributionEntity> distributions;
  late CaisseSummaryEntity caisseSummary;
  late List<LoanEntity> loans;
  late List<AidEventEntity> aidEvents;
  late List<MeetingEntity> meetings;

  bool isBackendConnected = false;
  DateTime? lastSyncTime;
  String? lastSyncError;

  final ApiClient _api = ApiClient.instance;

  /// Adhésion de l'utilisateur connecté, par tontine (clé : id numérique serveur).
  final Map<int, int> _myAdhesionByTontine = {};

  /// Caisse principale de chaque tontine (clé : id numérique de la tontine).
  final Map<int, int> _caisseByTontine = {};

  /// Caisses par tontine et par catégorie (PRINCIPALE_ROTATIVE, PRETS, SECOURS_ENTRAIDE...).
  final Map<int, Map<String, int>> _caisseByCategory = {};

  /// Cycle en cours de chaque tontine (`cycleEnCours.id`, contrat §1.1.B).
  final Map<int, int> _cycleByTontine = {};

  /// Ordre de passage du cycle en cours, par tontine (contrat §1.9).
  final Map<int, List<TurnEntity>> turnOrders = {};

  int? cycleIdFor(int? tontineId) =>
      tontineId == null ? null : _cycleByTontine[tontineId];

  List<TurnEntity> turnsFor(int? tontineId) =>
      tontineId == null ? const [] : (turnOrders[tontineId] ?? const []);

  int? caisseIdFor(int? tontineId, String category) {
    if (tontineId == null) return null;
    return _caisseByCategory[tontineId]?[category] ?? _caisseByTontine[tontineId];
  }

  static int? numericId(String id) =>
      int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), ''));

  /// Adhésion de l'utilisateur connecté dans la tontine donnée (id serveur).
  int? adhesionIdIn(int? tontineId) {
    if (tontineId != null && _myAdhesionByTontine.containsKey(tontineId)) {
      return _myAdhesionByTontine[tontineId];
    }
    return null;
  }

  /// Adhésion de l'utilisateur dans la tontine active (ou la première connue).
  int? get currentUserAdhesionId =>
      adhesionIdIn(activeTontineId) ??
      (_myAdhesionByTontine.isEmpty ? null : _myAdhesionByTontine.values.first);

  /// Adhésion de l'utilisateur dans la même tontine que l'adhésion donnée.
  int? currentUserAdhesionIdFor(int otherAdhesionId) {
    for (final t in tontines) {
      if (t.members.any((m) => numericId(m.id) == otherAdhesionId)) {
        return adhesionIdIn(numericId(t.id));
      }
    }
    return currentUserAdhesionId;
  }

  final List<Map<String, dynamic>> _inAppNotifications = [
    {
      'id': '1',
      'titre': '⚠️ Signalement Pénalité de retard',
      'contenu': 'Une pénalité a été appliquée pour retard de versement (membre ayant déjà bénéficié du tour).',
      'type': 'PENALITE',
      'date': '2026-11-02T12:00:00Z',
    },
    {
      'id': '2',
      'titre': '📢 Prochaine Réunion statutaire',
      'contenu': 'Ordre du jour : Cotisations du tour #7 et remise de la cagnotte.',
      'type': 'REUNION',
      'date': '2026-11-01T10:00:00Z',
    },
  ];

  List<Map<String, dynamic>> get myInAppNotifications => List.unmodifiable(_inAppNotifications);

  void removeInAppNotification(String id) {
    _inAppNotifications.removeWhere((n) => n['id'].toString() == id);
  }

  void clearAllInAppNotifications() {
    _inAppNotifications.clear();
  }

  void addInAppNotification({
    required String title,
    required String message,
    String type = 'PENALITE',
  }) {
    _inAppNotifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'titre': title,
      'contenu': message,
      'type': type,
      'date': DateTime.now().toIso8601String(),
    });
  }

  int? get primaryTontineId => activeTontineId ??
      (tontines.isEmpty ? null : numericId(tontines.first.id));

  int? caisseIdIn(int? tontineId) =>
      tontineId == null ? null : _caisseByTontine[tontineId];

  int? get primaryCaisseId =>
      caisseIdIn(primaryTontineId) ??
      (_syncedCaisseIds.isEmpty ? null : _syncedCaisseIds.first);

  final List<int> _syncedCaisseIds = [];

  // ------------------------------------------------------------------
  // Cloisonnement multi-tenant : seules les données renvoyées par le backend
  // pour l'utilisateur connecté sont conservées en mémoire.
  // ------------------------------------------------------------------

  /// Identifiant de la tontine active (celle affichée / gérée par défaut).
  int? activeTontineId;

  /// Utilisateurs visibles (GET /api/comptes/utilisateurs/) : pour un
  /// président = les personnes qu'il a invitées / ses membres.
  List<Map<String, dynamic>> visibleUsers = [];

  /// Invitations émises (GET /api/comptes/mes-invites/).
  List<Map<String, dynamic>> sentInvites = [];

  /// Nom de la tontine rejointe à l'inscription (réponse register).
  String? pendingTontineName;

  /// Identifiant utilisateur de chaque adhésion (clé : id du membre affiché).
  final Map<String, String> _memberUserIds = {};

  /// Efface toutes les données métier en mémoire (changement d'utilisateur).
  void clearBusinessData() {
    tontines = <TontineEntity>[];
    members = <MemberEntity>[];
    transactions = <TransactionEntity>[];
    distributions = <DistributionEntity>[];
    loans = <LoanEntity>[];
    aidEvents = <AidEventEntity>[];
    meetings = <MeetingEntity>[];
    caisseSummary = CaisseSummaryEntity(
      theoreticalBalance: 0,
      availableCashBalance: 0,
      mobileMoneyBalance: 0,
      bankBalance: 0,
      totalIncome: 0,
      totalExpense: 0,
      pendingValidationAmount: 0,
      recentEntries: <CaisseEntryEntity>[],
    );
    _syncedCaisseIds.clear();
    _myAdhesionByTontine.clear();
    _caisseByTontine.clear();
    _caisseByCategory.clear();
    _cycleByTontine.clear();
    turnOrders.clear();
    _memberUserIds.clear();
    visibleUsers = [];
    sentInvites = [];
    activeTontineId = null;
    isBackendConnected = false;
    lastSyncError = null;
  }

  List<dynamic> _asList(dynamic value, [List<String> keys = const []]) {
    if (value is List) return value;
    if (value is Map) {
      for (final k in [...keys, 'results', 'data', 'items']) {
        final v = value[k];
        if (v is List) return v;
      }
    }
    return const [];
  }

  int? _intId(dynamic v) => int.tryParse(v?.toString() ?? '');

  String _digits(String v) => v.replaceAll(RegExp(r'\D'), '');

  MemberRole _roleFrom(dynamic rolesRaw) {
    final roles = rolesRaw is List
        ? rolesRaw.map((e) => e.toString().toUpperCase()).toList()
        : <String>[if (rolesRaw != null) rolesRaw.toString().toUpperCase()];
    if (roles.contains('PRESIDENT') || roles.contains('FONDATEUR')) {
      return MemberRole.president;
    }
    if (roles.contains('TRESORIER')) return MemberRole.tresorier;
    if (roles.contains('SECRETAIRE')) return MemberRole.secretaire;
    if (roles.contains('CONTROLEUR') || roles.contains('COMMISSAIRE')) {
      return MemberRole.commissaire;
    }
    return MemberRole.membre;
  }

  MemberEntity _memberFromJson(Map<String, dynamic> m, int index, double cotisation, {int numMembers = 1}) {
    final role = _roleFrom(m['roles'] ?? m['role']);
    final fullName = (m['nom'] ?? m['utilisateur_nom'] ?? 'Membre ${m['id']}').toString();
    final initials = fullName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    final statut = (m['statut'] ?? '').toString().toUpperCase();
    final statutCotisation = (m['statutCotisation'] ?? '').toString().toUpperCase();
    final enRetard = statutCotisation == 'EN_RETARD' || _num(m['nombreRetards']) > 0;
    final memberKey = 'mem-${m['adhesion_id'] ?? m['id']}';
    final userId = (m['utilisateur_id'] ?? m['user_id'] ?? m['utilisateur'])?.toString();
    if (userId != null && userId.isNotEmpty) _memberUserIds[memberKey] = userId;
    final expected = m['totalAttendu'] != null
        ? _num(m['totalAttendu'])
        : (cotisation * (numMembers > 0 ? numMembers : 1));
    return MemberEntity(
      id: memberKey,
      fullName: fullName,
      phone: (m['telephone'] ?? '').toString(),
      email: (m['email'] ?? '').toString(),
      role: role,
      status: statut == 'EN_ATTENTE' || statut == 'INVITE'
          ? MemberStatus.invite
          : (statut == 'SUSPENDU' || statut == 'EXCLU' || statut == 'DEMISSIONNAIRE')
              ? MemberStatus.suspendu
              : (enRetard ? MemberStatus.retard : MemberStatus.actif),
      avatarInitials: initials.isEmpty ? 'TL' : initials,
      totalContributed: _num(m['totalCotise']),
      totalExpected: expected,
      latePaymentsCount: _num(m['nombreRetards']).toInt(),
      joinedDate: DateTime.tryParse((m['dateEntree'] ?? '').toString()) ?? DateTime.now(),
      payoutTurn: index + 1,
      roleAssignedBy: '',
      roleAssignedDate: null,
      contributionStatus: statutCotisation,
      canContribute: m['peutCotiser'] is bool ? m['peutCotiser'] as bool : true,
      unpaidPenaltiesCount: _num(m['penalitesImpayeesCount']).toInt(),
      unpaidPenaltiesAmount: _num(m['penalitesImpayeesMontant']),
    );
  }

  String _initials(String name) {
    final i = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    return i.isEmpty ? '—' : i;
  }

  TurnStatus _turnStatusFrom(dynamic v) => switch (v?.toString().toUpperCase()) {
        'PRETE_A_DISTRIBUER' => TurnStatus.preteADistribuer,
        'EFFECTUEE' => TurnStatus.effectuee,
        'CONFIRMEE' => TurnStatus.confirmee,
        _ => TurnStatus.programmee,
      };

  TurnEntity _turnFromJson(Map<String, dynamic> j, int cycleId) => TurnEntity(
        id: _intId(j['id']) ?? 0,
        cycleId: _intId(j['cycle_id']) ?? cycleId,
        rank: _intId(j['rang']) ?? 0,
        adhesionId: _intId(j['adhesion_id']) ?? 0,
        memberName: (j['membre_nom'] ?? '').toString(),
        phone: (j['telephone'] ?? '').toString(),
        plannedDate: DateTime.tryParse((j['datePrevue'] ?? '').toString()),
        plannedAmount: _num(j['montantPrevu']),
        collectedAmount: _num(j['montantCollecte']),
        status: _turnStatusFrom(j['statutTour']),
        distributionId: _intId(j['distribution_id']),
        distributionStatus: (j['distribution_statut'] ?? '').toString(),
      );

  /// Trouve l'adhésion de l'utilisateur connecté parmi les membres d'une tontine.
  int? _findMyAdhesion(List<MemberEntity> list) {
    final phone = _digits(currentUser.phone);
    final email = currentUser.email.toLowerCase();
    for (final m in list) {
      final samePhone = phone.isNotEmpty && _digits(m.phone) == phone;
      final sameEmail = email.isNotEmpty && m.email.toLowerCase() == email;
      final sameUserId =
          currentUser.id.isNotEmpty && _memberUserIds[m.id] == currentUser.id;
      if (samePhone || sameEmail || sameUserId) return numericId(m.id);
    }
    return null;
  }

  /// Retrouve le rôle réel de l'utilisateur connecté dans ses tontines.
  void _refreshCurrentUserRole() {
    if (members.isEmpty) return;
    final phone = _digits(currentUser.phone);
    final email = currentUser.email.toLowerCase();
    for (final m in members) {
      final samePhone = phone.isNotEmpty && _digits(m.phone) == phone;
      final sameEmail = email.isNotEmpty && m.email.toLowerCase() == email;
      final sameUserId = currentUser.id.isNotEmpty && _memberUserIds[m.id] == currentUser.id;
      if (samePhone || sameEmail || sameUserId) {
        UserRole r = UserRole.membre;
        switch (m.role) {
          case MemberRole.president:
            r = UserRole.president;
            break;
          case MemberRole.tresorier:
            r = UserRole.tresorier;
            break;
          case MemberRole.secretaire:
            r = UserRole.secretaire;
            break;
          case MemberRole.commissaire:
            r = UserRole.commissaire;
            break;
          case MemberRole.membre:
            r = UserRole.membre;
            break;
        }
        currentUser = currentUser.copyWith(activeRole: r);
        return;
      }
    }
  }

  /// Synchronise tous les modules avec l'API Django REST.
  ///
  /// Le backend applique le cloisonnement : on ne reçoit que les tontines
  /// dont l'utilisateur est membre, et que les utilisateurs autorisés.
  Future<bool> syncFromBackend() async {
    try {
      if (!_api.hasToken) {
        lastSyncError = 'Connexion requise avant la synchronisation.';
        isBackendConnected = false;
        return false;
      }

      final apiIndex = await _api.get('/api/');
      if (!apiIndex.isOk) {
        isBackendConnected = false;
        lastSyncError = 'Impossible de se connecter au serveur.';
        return false;
      }
      final syncErrors = <String>[];

      final newTontines = <TontineEntity>[];
      final newMembers = <MemberEntity>[];
      final newTxns = <TransactionEntity>[];
      final newDist = <DistributionEntity>[];
      final newMeets = <MeetingEntity>[];
      final caisseIds = <int>[];
      final soldeByTontine = <int, double>{};
      double totalSolde = 0;
      double totalReserve = 0;

      // 1. Mes tontines (uniquement celles dont je suis membre)
      final listRes = await _api.get('/api/tontines/');
      if (!listRes.isOk) {
        syncErrors.add('tontines (${listRes.statusCode})');
      }
      final rawTontines = listRes.isOk ? _asList(listRes.data, ['tontines']) : const [];

      for (final raw in rawTontines.whereType<Map<String, dynamic>>()) {
        final tid = _intId(raw['id'] ?? raw['tontine_id']);
        if (tid == null) continue;

        final detailRes = await _api.get('/api/tontines/$tid/');
        final detail = detailRes.isOk && detailRes.data is Map<String, dynamic>
            ? detailRes.data as Map<String, dynamic>
            : <String, dynamic>{};
        final tInfo = (detail['tontine'] is Map<String, dynamic>)
            ? detail['tontine'] as Map<String, dynamic>
            : raw;
        final regle = detail['regle'] as Map<String, dynamic>?;
        final cycle = detail['cycleEnCours'] as Map<String, dynamic>?;
        final cotisation = (regle?['cotisation'] as num?)?.toDouble() ??
            (tInfo['cotisation'] as num?)?.toDouble() ??
            0;

        // Membres de CETTE tontine (réservé aux membres actifs côté serveur)
        final memRes = await _api.get('/api/tontines/$tid/membres/');
        var rawMembers = memRes.isOk ? _asList(memRes.data, ['membres']) : const [];
        if (rawMembers.isEmpty) rawMembers = _asList(detail['membres']);
        final numMembers = rawMembers.length;
        final tMembers = <MemberEntity>[];
        for (var i = 0; i < rawMembers.length; i++) {
          final m = rawMembers[i];
          if (m is Map<String, dynamic>) {
            tMembers.add(_memberFromJson(m, i, cotisation, numMembers: numMembers));
          }
        }

        // Ordre de passage du cycle en cours (GET /api/tontines/cycles/<id>/ordre-passage/)
        final cycleId = _intId(cycle?['id']);
        var turns = <TurnEntity>[];
        if (cycleId != null) {
          _cycleByTontine[tid] = cycleId;
          final turnRes = await _api.get('/api/tontines/cycles/$cycleId/ordre-passage/');
          if (turnRes.isOk) {
            turns = _asList(turnRes.data)
                .whereType<Map<String, dynamic>>()
                .map((j) => _turnFromJson(j, cycleId))
                .toList()
              ..sort((a, b) => a.rank.compareTo(b.rank));
          } else {
            syncErrors.add('ordre de passage (${turnRes.statusCode})');
          }
        }
        turnOrders[tid] = turns;
        for (var i = 0; i < tMembers.length; i++) {
          final aid = numericId(tMembers[i].id);
          final mine = turns.where((x) => x.adhesionId == aid);
          if (mine.isNotEmpty) {
            tMembers[i] = tMembers[i].copyWith(payoutTurn: mine.first.rank);
          }
        }
        final nextTurns = turns.where((x) => !x.isFinished);
        final nextTurn = nextTurns.isEmpty ? null : nextTurns.first;
        if (activeTontineId == null || activeTontineId == tid || newTontines.isEmpty) {
          if (newTontines.isEmpty) newMembers.addAll(tMembers);
        }

        final myAdhesion = _findMyAdhesion(tMembers);
        if (myAdhesion != null) _myAdhesionByTontine[tid] = myAdhesion;

        final safeCount = tMembers.isEmpty ? 1 : tMembers.length;
        newTontines.add(TontineEntity(
          id: 'tontine-$tid',
          name: (tInfo['nom'] ?? tInfo['tontine_nom'] ?? 'Tontine $tid').toString(),
          description: (tInfo['description'] ?? '').toString(),
          type: _typeFrom(tInfo['type']),
          frequency: _frequencyFrom(regle?['frequence'] ?? tInfo['frequence']),
          status: _statusFrom(tInfo['statut']),
          distributionMethod: _distributionFrom(regle?['modeDistribution'] ?? tInfo['modeDistribution']),
          contributionAmount: cotisation,
          totalCycleAmount: cotisation * safeCount > 0 ? cotisation * safeCount : 1,
          memberCount: tMembers.length,
          maxMembers: (raw['membreMax'] as num?)?.toInt() ?? (tInfo['membreMax'] as num?)?.toInt() ?? tMembers.length,
          nextDueDate: DateTime.tryParse(
                  (cycle?['prochaineEcheance'] ?? cycle?['dateFin'] ?? tInfo['prochaineEcheance'] ?? '').toString()) ??
              DateTime.now(),
          nextBeneficiaryName: nextTurn?.memberName ?? '—',
          nextBeneficiaryAvatar: nextTurn == null ? '—' : _initials(nextTurn.memberName),
          currentCycle: int.tryParse((cycle?['numero'] ?? '1').toString()) ?? 1,
          totalCycles: (tInfo['dureeCycle'] as num?)?.toInt() ?? tMembers.length,
          collectedAmountThisPeriod: _num(cycle?['montantCollecte']),
          cashReserveBalance: 0,
          isPrivate: tInfo['privee'] is bool ? tInfo['privee'] as bool : true,
          coverTag: (tInfo['categorie'] ?? 'Tontine').toString(),
          members: tMembers,
        ));

        // 2. Cotisations de la tontine
        final cotisRes = await _api.get('/api/finances/cotisations/?tontine_id=$tid');
        if (!cotisRes.isOk) {
          syncErrors.add('cotisations (${cotisRes.statusCode})');
        } else {
          for (final c in _asList(cotisRes.data).whereType<Map<String, dynamic>>()) {
            final modeStr = (c['mode']?.toString() ?? '').toUpperCase();
            final statutStr = (c['statut']?.toString() ?? '').toUpperCase();
            newTxns.add(TransactionEntity(
              id: 'TXN-${c['id']}',
              tontineName: (c['tontine_nom'] ?? tInfo['nom'] ?? '').toString(),
              memberName: (c['membre_nom'] ?? 'Membre').toString(),
              type: TransactionType.cotisation,
              amount: (c['montant'] as num?)?.toDouble() ?? 0,
              // ESPECES / MOBILE_MONEY / VIREMENT / CARTE (CARTE rattachée à « virement »)
              paymentMethod: switch (modeStr) {
                'ESPECES' || 'SEANCE' => PaymentMethod.especes,
                'VIREMENT' || 'CARTE' => PaymentMethod.virement,
                'ORANGE_MONEY' => PaymentMethod.orangeMoney,
                _ => PaymentMethod.mtnMoMo,
              },
              // DECLAREE / EN_ATTENTE_VALIDATION restent « à valider » par le bureau.
              status: switch (statutStr) {
                'VALIDEE' => TransactionStatus.confirme,
                'ECHOUEE' => TransactionStatus.echoue,
                'ANNULEE' => TransactionStatus.annule,
                _ => TransactionStatus.aVerifier,
              },
              date: DateTime.tryParse((c['date'] ?? '').toString()) ?? DateTime.now(),
              reference: (c['referencePaiement'] ?? 'COT-${c['id']}').toString(),
              validatedBy: null,
              note: 'Cotisation',
            ));
          }
        }

        // 3. Caisses
        final caisseRes = await _api.get('/api/finances/caisses/tontine/$tid/');
        if (!caisseRes.isOk) {
          syncErrors.add('caisses (${caisseRes.statusCode})');
        } else {
          for (final c in _asList(caisseRes.data).whereType<Map<String, dynamic>>()) {
            final cid = _intId(c['id']);
            if (cid != null) {
              caisseIds.add(cid);
              if ((c['categorie'] ?? '') == 'PRINCIPALE_ROTATIVE') {
                _caisseByTontine[tid] = cid;
              } else {
                _caisseByTontine.putIfAbsent(tid, () => cid);
              }
              _caisseByCategory.putIfAbsent(tid, () => {})[(c['categorie'] ?? '').toString()] = cid;
            }
            soldeByTontine[tid] = (soldeByTontine[tid] ?? 0) + _num(c['soldeDisponible']);
            totalSolde += (c['soldeDisponible'] as num?)?.toDouble() ?? 0;
            totalReserve += (c['montantReserve'] as num?)?.toDouble() ?? 0;
          }
        }

        // 4. Distributions
        final distRes = await _api.get('/api/finances/distributions/?tontine_id=$tid');
        if (!distRes.isOk) {
          syncErrors.add('distributions (${distRes.statusCode})');
        } else {
          final list = _asList(distRes.data).whereType<Map<String, dynamic>>().toList();
          for (var i = 0; i < list.length; i++) {
            final d = list[i];
            final prevu = (d['montantPrevu'] as num?)?.toDouble() ?? 0;
            final valide = (d['montantValide'] as num?)?.toDouble() ?? prevu;
            final frais = (d['fraisDeduits'] as num?)?.toDouble() ?? 0;
            final statutStr = d['statut']?.toString() ?? '';
            // PROGRAMMEE -> EFFECTUEE (après executer) -> CONFIRMEE (après confirmer)
            var st = DistributionStatus.enCollecte;
            if (statutStr == 'CONFIRMEE') {
              st = DistributionStatus.distribuee;
            } else if (statutStr == 'EFFECTUEE' || statutStr == 'VALIDEE') {
              st = DistributionStatus.validee;
            } else if (statutStr == 'CONTESTEE') {
              st = DistributionStatus.litige;
            }
            newDist.add(DistributionEntity(
              id: 'DIST-${d['id']}',
              tontineId: 'tontine-$tid',
              tontineName: (d['tontine_nom'] ?? tInfo['nom'] ?? '').toString(),
              beneficiaryName: (d['beneficiaire_nom'] ?? '').toString(),
              beneficiaryPhone: (d['beneficiaire_telephone'] ?? '').toString(),
              turnNumber: i + 1,
              scheduledDate: DateTime.tryParse((d['date'] ?? '').toString()) ?? DateTime.now(),
              theoreticalAmount: prevu,
              availableAmount: valide,
              deductionFees: frais,
              netAmount: valide - frais,
              status: st,
              approvedByPresident: null,
              approvedByTreasurer: null,
            ));
          }
        }

        // 5. Réunions
        final meetRes = await _api.get('/api/tontines/$tid/reunions/');
        if (!meetRes.isOk) {
          syncErrors.add('réunions (${meetRes.statusCode})');
        } else {
          for (final r in _asList(meetRes.data).whereType<Map<String, dynamic>>()) {
            final dt = DateTime.tryParse((r['date'] ?? '').toString()) ?? DateTime.now();
            final isPast = dt.isBefore(DateTime.now());
            // PLANIFIEE / EN_COURS / TENUE / ANNULEE (repli sur la date si absent)
            final meetStatus = switch ((r['statut'] ?? '').toString().toUpperCase()) {
              'PLANIFIEE' => MeetingStatus.aVenir,
              'EN_COURS' => MeetingStatus.enCours,
              'TENUE' || 'ANNULEE' => MeetingStatus.cloturee,
              _ => isPast ? MeetingStatus.cloturee : MeetingStatus.aVenir,
            };
            newMeets.add(MeetingEntity(
              id: 'MEET-${r['id']}',
              tontineId: 'tontine-$tid',
              tontineName: (tInfo['nom'] ?? '').toString(),
              title: (r['ordreDuJour'] ?? 'Réunion').toString(),
              dateTime: dt,
              location: (r['lieu'] ?? '').toString(),
              hostName: '',
              status: meetStatus,
              attendeesCount: 0,
              totalExpectedMembers: tMembers.length,
              totalCashCollected: 0,
              minutesSummary: (r['ordreDuJour'] ?? '').toString(),
              attendanceList: tMembers
                  .map((m) => AttendanceItemEntity(
                        memberId: m.id,
                        memberName: m.fullName,
                        isPresent: false,
                        cashContributed: 0,
                        note: m.roleDisplayName,
                      ))
                  .toList(),
            ));
          }
        }
      }

      tontines = newTontines.map((t) {
        final tid = numericId(t.id);
        final collected = newTxns
            .where((x) => x.tontineName == t.name && x.status == TransactionStatus.confirme)
            .fold<double>(0, (sum, x) => sum + x.amount);
        return t.copyWith(
          collectedAmountThisPeriod: collected,
          cashReserveBalance: tid == null ? 0 : (soldeByTontine[tid] ?? 0),
        );
      }).toList();
      members = newMembers;
      transactions = newTxns;
      distributions = newDist;
      meetings = newMeets;
      _syncedCaisseIds
        ..clear()
        ..addAll(caisseIds);
      // Mouvements de caisse (GET /api/finances/caisses/<id>/transactions/)
      final entries = <CaisseEntryEntity>[];
      for (final cid in caisseIds) {
        final txRes = await _api.get('/api/finances/caisses/$cid/transactions/');
        if (!txRes.isOk) continue;
        for (final j in _asList(txRes.data, ['transactions']).whereType<Map<String, dynamic>>()) {
          final type = (j['type'] ?? '').toString().toUpperCase();
          final st = (j['statut'] ?? '').toString().toUpperCase();
          if (st == 'ECHOUEE' || st == 'CONTREPASSEE') continue;
          const credits = {'COTISATION', 'AIDE_CONTRIBUTION', 'PRET_REMBOURSEMENT', 'PENALITE', 'FRAIS'};
          final credit = credits.contains(type);
          entries.add(CaisseEntryEntity(
            id: 'CE-$cid-${j['id']}',
            date: DateTime.tryParse((j['date'] ?? '').toString()) ?? DateTime.now(),
            title: _transactionLabel(type),
            category: switch (type) {
              'COTISATION' => CaisseCategory.cotisation,
              'AIDE_CONTRIBUTION' => CaisseCategory.fondSecours,
              'AIDE_VERSEMENT' => CaisseCategory.aideSociale,
              'PRET_REMBOURSEMENT' => CaisseCategory.remboursementPret,
              'PENALITE' || 'FRAIS' => CaisseCategory.fraisAdhesion,
              _ => CaisseCategory.depenseFonctionnement,
            },
            amount: _num(j['montant']),
            isCredit: credit,
            performedBy: '',
            isReconciled: st == 'VALIDEE',
            proofReference: (j['referenceExterne'] ?? '').toString(),
          ));
        }
      }
      entries.sort((a, b) => b.date.compareTo(a.date));
      final income = entries.where((e) => e.isCredit).fold<double>(0, (a, e) => a + e.amount);
      final expense = entries.where((e) => !e.isCredit).fold<double>(0, (a, e) => a + e.amount);
      caisseSummary = CaisseSummaryEntity(
        theoreticalBalance: totalSolde + totalReserve,
        availableCashBalance: 0,
        mobileMoneyBalance: totalSolde,
        bankBalance: 0,
        totalIncome: income,
        totalExpense: expense,
        pendingValidationAmount: 0,
        recentEntries: entries.take(50).toList(),
      );
      final keepActive = activeTontineId;
      final stillThere = keepActive != null &&
          newTontines.any((t) => numericId(t.id) == keepActive);
      activeTontineId = newTontines.isEmpty
          ? null
          : (stillThere ? keepActive : numericId(newTontines.first.id));
      _refreshCurrentUserRole();

      // 6. Utilisateurs visibles + invitations émises (cloisonnement serveur)
      final usersRes = await _api.get('/api/comptes/utilisateurs/');
      visibleUsers = usersRes.isOk
          ? _asList(usersRes.data, ['utilisateurs']).whereType<Map<String, dynamic>>().toList()
          : <Map<String, dynamic>>[];
      final invRes = await _api.get('/api/comptes/mes-invites/');
      sentInvites = invRes.isOk
          ? _asList(invRes.data, ['invitations']).whereType<Map<String, dynamic>>().toList()
          : <Map<String, dynamic>>[];

      // 7. Prêts et événements d'entraide (lecture seule depuis la base)
      final demandesRes = await _api.get('/api/prets/demandes/');
      final pretsRes = await _api.get('/api/prets/');
      final demandes = demandesRes.isOk
          ? _asList(demandesRes.data, ['demandes', 'prets'])
              .whereType<Map<String, dynamic>>()
              .map((j) => _loanFromJson(j, isDemande: true))
              .toList()
          : <LoanEntity>[];
      final prets = pretsRes.isOk
          ? _asList(pretsRes.data, ['prets'])
              .whereType<Map<String, dynamic>>()
              .map((j) => _loanFromJson(j))
              .toList()
          : <LoanEntity>[];
      // Une demande décaissée apparaît aussi comme prêt : on garde le prêt.
      final pretDemandeIds = <String>{};
      for (final j in _asList(pretsRes.data, ['prets']).whereType<Map<String, dynamic>>()) {
        final d = j['demande_id'] ?? j['demande'];
        if (d != null) pretDemandeIds.add('DEM-${d is Map ? d['id'] : d}');
      }
      loans = [
        ...prets,
        ...demandes.where((d) => !pretDemandeIds.contains(d.id)),
      ];
      final aidRes = await _api.get('/api/entraide/evenements/');
      aidEvents = aidRes.isOk
          ? _asList(aidRes.data, ['evenements'])
              .whereType<Map<String, dynamic>>()
              .map(_aidFromJson)
              .toList()
          : <AidEventEntity>[];

      isBackendConnected = true;
      lastSyncTime = DateTime.now();
      lastSyncError = syncErrors.isEmpty
          ? null
          : 'Endpoints non synchronisés : ${syncErrors.join(', ')}.';
      return true;
    } catch (e) {
      isBackendConnected = false;
      lastSyncError = e.toString();
      return false;
    }
  }

  TontineType _typeFrom(dynamic v) => switch (v?.toString().toUpperCase()) {
        'CUMULATIVE' => TontineType.cumulative,
        'PRET' => TontineType.avecPrets,
        'ENTRAIDE' => TontineType.entraide,
        'PROJET_COMMERCIAL' => TontineType.projetCollectif,
        _ => TontineType.rotative,
      };

  TontineFrequency _frequencyFrom(dynamic v) => switch (v?.toString().toUpperCase()) {
        'HEBDOMADAIRE' => TontineFrequency.hebdomadaire,
        'QUINZOMADAIRE' => TontineFrequency.bimensuelle,
        _ => TontineFrequency.mensuelle,
      };

  TontineStatus _statusFrom(dynamic v) => switch (v?.toString().toUpperCase()) {
        'CREEE' => TontineStatus.enPreparation,
        'SUSPENDUE' => TontineStatus.suspendue,
        'CLOTUREE' => TontineStatus.cloturee,
        _ => TontineStatus.active,
      };

  DistributionMethod _distributionFrom(dynamic v) => switch (v?.toString().toUpperCase()) {
        'TIRAGE_SORT' => DistributionMethod.tirageAuSort,
        'ENCHERE' || 'ACCORD_MUTUEL' => DistributionMethod.personnalise,
        _ => DistributionMethod.ordrePredefini,
      };

  String _transactionLabel(String type) => switch (type) {
        'COTISATION' => 'Cotisation',
        'AIDE_CONTRIBUTION' => 'Contribution d\'entraide',
        'PRET_REMBOURSEMENT' => 'Remboursement de prêt',
        'PENALITE' => 'Pénalité',
        'FRAIS' => 'Frais',
        'DISTRIBUTION' => 'Distribution',
        'PRET_DECAISSEMENT' => 'Décaissement de prêt',
        'AIDE_VERSEMENT' => 'Versement d\'aide',
        'PROJET_OPERATION' => 'Opération de projet',
        'AJUSTEMENT' => 'Ajustement',
        _ => type,
      };

  double _num(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

  LoanEntity _loanFromJson(Map<String, dynamic> j, {bool isDemande = false}) {
    final st = (j['statut'] ?? '').toString().toUpperCase();
    final montant = _num(isDemande ? j['montant'] : j['montantAccorde']);
    final reste = isDemande ? montant : _num(j['soldeRestantDu']);
    final rembourse = isDemande ? 0.0 : (montant - reste).clamp(0, double.infinity).toDouble();
    var status = LoanStatus.enAttente;
    if (isDemande) {
      if (st == 'APPROUVEE') {
        status = LoanStatus.approuve;
      } else if (st == 'REJETEE' || st == 'ANNULEE') {
        status = LoanStatus.rejete;
      }
    } else {
      status = switch (st) {
        'REMBOURSE' || 'CLOTURE' => LoanStatus.solde,
        'EN_DEFAUT' => LoanStatus.enRetard,
        _ => LoanStatus.enRemboursement,
      };
    }
    final start = DateTime.tryParse((j['dateDecaissement'] ?? j['dateDemande'] ?? '').toString());
    final end = DateTime.tryParse((j['dateEcheanceFinale'] ?? '').toString());
    final months = isDemande
        ? _num(j['dureeSouhaitee']).toInt()
        : (start != null && end != null
            ? ((end.year - start.year) * 12 + end.month - start.month)
            : 0);
    return LoanEntity(
      id: '${isDemande ? 'DEM' : 'LOAN'}-${j['id']}',
      borrowerName: (j['demandeur_nom'] ?? j['emprunteur_nom'] ?? '').toString(),
      borrowerPhone: '',
      amountRequested: montant,
      purpose: (j['motif'] ?? (isDemande ? '' : 'Prêt accordé')).toString(),
      interestRatePercent: _num(j['tauxInteret']),
      rateType: (j['typeTaux'] ?? 'FIXE').toString().toUpperCase() == 'VARIABLE' ? 'VARIABLE' : 'FIXE',
      durationMonths: months,
      amountRepaid: rembourse,
      remainingDue: reste,
      status: status,
      requestDate: start ?? DateTime.now(),
      dueDate: end,
      tontineId: _intId(j['tontine_id'] ?? j['tontine']),
      tontineName: (j['tontine_nom'] ?? '').toString(),
    );
  }

  AidEventEntity _aidFromJson(Map<String, dynamic> j) {
    final type = switch ((j['type'] ?? '').toString().toUpperCase()) {
      'DECES' => AidEventType.deces,
      'MALADIE' => AidEventType.maladie,
      'NAISSANCE' => AidEventType.naissance,
      'MARIAGE' => AidEventType.mariage,
      _ => AidEventType.autreSecours,
    };
    final status = switch ((j['statut'] ?? '').toString().toUpperCase()) {
      'VALIDE' => AidEventStatus.valide,
      'CLOTURE' => AidEventStatus.debourse,
      'REJETE' => AidEventStatus.rejete,
      _ => AidEventStatus.soumis, // DECLARE, EN_ATTENTE_VALIDATION
    };
    final cible = _num(j['montantCible']);
    return AidEventEntity(
      id: 'AID-${j['id']}',
      title: (j['description'] ?? 'Entraide').toString(),
      memberName: (j['beneficiaire_nom'] ?? '').toString(),
      type: type,
      requestedAmount: cible,
      approvedAmount: cible,
      status: status,
      date: DateTime.tryParse((j['dateEvenement'] ?? '').toString()) ?? DateTime.now(),
      justification: (j['tontine_nom'] ?? '').toString(),
      tontineId: _intId(j['tontine_id'] ?? j['tontine']),
      tontineName: (j['tontine_nom'] ?? '').toString(),
    );
  }

  /// Crée une tontine côté serveur (POST /api/tontines/), relit les données,
  /// puis garantit que le créateur est Président de la tontine créée.
  Future<ApiResponse> createTontine(Map<String, dynamic> body) async {
    final response = await _api.post('/api/tontines/', body);
    if (!response.isOk) return response;
    final data = response.data;
    final created = data is Map<String, dynamic> && data['tontine'] is Map<String, dynamic>
        ? data['tontine'] as Map<String, dynamic>
        : data is Map<String, dynamic>
            ? data
            : const <String, dynamic>{};
    // Le serveur attribue automatiquement FONDATEUR + PRESIDENT au créateur.
    final newId = _intId(created['tontine_id'] ?? created['id']);
    final creatorAdhesion = _intId(created['adhesion_id']);
    await syncFromBackend();
    if (newId != null) {
      activeTontineId = newId;
      // La réponse 201 donne directement l'adhésion du créateur.
      if (creatorAdhesion != null) {
        _myAdhesionByTontine.putIfAbsent(newId, () => creatorAdhesion);
      }
    }
    return response;
  }

  /// Invite un membre dans une tontine (canal LIEN ou EMAIL).
  /// Retourne la réponse brute : `data['code']` contient le code d'invitation.
  Future<ApiResponse> inviteMember({
    required int tontineId,
    required String canal,
    required String destinataire,
  }) {
    return _api.post('/api/tontines/$tontineId/inviter/', {
      'canal': canal,
      'destinataire': destinataire,
    });
  }


  /// Rejoint une tontine avec un code d'invitation (utilisateur déjà connecté).
  Future<ApiResponse> joinTontine(String code) {
    return _api.post('/api/tontines/rejoindre/', {'code': code});
  }

  /// Étape 2 : Validation du code e-mail (Activation finale)
  Future<ApiResponse> verifyEmail({required String email, required String code}) {
    return _api.post('/api/comptes/auth/register/verify-email/', {
      'email': email,
      'code': code,
    });
  }

  /// Étape de secours : Renvoyer le code OTP
  Future<ApiResponse> resendCode(String email) {
    return _api.post('/api/comptes/auth/register/resend-code/', {
      'email': email,
    });
  }

  /// Section 15.3 : Demande de code OTP par WhatsApp
  Future<ApiResponse> requestOtpWhatsApp({
    required String telephone,
    String objectif = 'CONNEXION',
  }) {
    return _api.post('/api/comptes/auth/otp/request/', {
      'telephone': telephone,
      'objectif': objectif,
    });
  }

  /// Section 15.4 : Test direct d'envoi WhatsApp (+237697951571)
  Future<ApiResponse> testWhatsAppSend({
    required String telephone,
    String nom = 'Membre',
  }) {
    return _api.post('/api/comptes/auth/whatsapp/test/', {
      'telephone': telephone,
      'nom': nom,
    });
  }

  /// Tableau de bord unique par rôle (GET /api/tontines/{tontine_id}/dashboard/)
  Future<ApiResponse> fetchDashboard(int tontineId) {
    return _api.get('/api/tontines/$tontineId/dashboard/');
  }

  /// Permissions de l'utilisateur connecté (GET /api/tontines/{tontine_id}/permissions/)
  Future<ApiResponse> fetchPermissions(int tontineId) {
    return _api.get('/api/tontines/$tontineId/permissions/');
  }

  /// Section 12 : Envoi direct des invitations (E-mail & WhatsApp) : POST /api/tontines/{tontine_id}/membres/inviter/
  Future<ApiResponse> inviteMemberDirectAdvanced({
    required int tontineId,
    required String canal,
    String? telephone,
    String? email,
    String roleNom = 'MEMBRE',
  }) {
    return _api.post('/api/tontines/$tontineId/membres/inviter/', {
      'canal': canal,
      if (telephone != null) 'telephone': telephone,
      if (email != null) 'email': email,
      'role_nom': roleNom,
    });
  }

  /// Section 13 : Calcul automatique du calendrier des tours : GET /api/tontines/{tontine_id}/cycles/calculer-calendrier/
  Future<ApiResponse> calculateCalendar({
    required int tontineId,
    required String dateDebut,
    required String frequence,
  }) {
    return _api.get('/api/tontines/$tontineId/cycles/calculer-calendrier/', queryParams: {
      'dateDebut': dateDebut,
      'frequence': frequence,
    });
  }

  /// Section 14 : Situation financière flexible : GET /api/finances/cotisations/situation/
  Future<ApiResponse> fetchMemberFinancialSituation(int tontineId) {
    return _api.get('/api/finances/cotisations/situation/', queryParams: {
      'tontine_id': tontineId.toString(),
    });
  }

  /// Calcul / Prévisualisation de pénalité différenciée (GET /api/tontines/{tontine_id}/penalites/calculer/)
  Future<ApiResponse> calculatePenalty({required int tontineId, required int adhesionId, required double montant}) {
    return _api.get('/api/tontines/$tontineId/penalites/calculer/', queryParams: {
      'adhesion_id': adhesionId.toString(),
      'montant': montant.toString(),
    });
  }

  /// Application d'une pénalité (POST /api/tontines/{tontine_id}/penalites/appliquer/)
  Future<ApiResponse> applyPenalty({
    required int tontineId,
    required int adhesionId,
    required double montant,
    required String motif,
    bool? forceMontant,
  }) async {
    addInAppNotification(
      title: '⚠️ Pénalité enregistrée (${montant.toInt()} FCFA)',
      message: 'Motif : $motif',
      type: 'PENALITE',
    );
    return _act('/api/tontines/$tontineId/penalites/appliquer/', {
      'adhesion_id': adhesionId,
      'montant': montant,
      'motif': motif,
      if (forceMontant != null) 'force_montant': forceMontant,
    });
  }

  /// Action : Attribuer un rôle à un membre (Sécurisé par le backend pour le Président)
  Future<bool> assignMemberRole({
    required int targetAdhesionId,
    required String roleName,
    required String memberId,
    required String assignedBy,
    int? tontineId,
  }) async {
    final tid = tontineId ?? activeTontineId;
    if (tid == null) return false;
    final response = await _api.post('/api/tontines/$tid/roles/assign/', {
      'target_adhesion_id': targetAdhesionId,
      'role_name': roleName,
      'replace': true,
    });
    if (!response.isOk) return false;

    final memberIndex = members.indexWhere(
      (m) => m.id == memberId || m.id == 'mem-$targetAdhesionId',
    );
    if (memberIndex != -1) {
      MemberRole newRole = MemberRole.membre;
      final upper = roleName.toUpperCase();
      if (upper.contains('PRESIDENT') || upper.contains('FONDATEUR')) {
        newRole = MemberRole.president;
      } else if (upper.contains('TRESORIER')) {
        newRole = MemberRole.tresorier;
      } else if (upper.contains('SECRETAIRE')) {
        newRole = MemberRole.secretaire;
      } else if (upper.contains('COMMISSAIRE') || upper.contains('CONTROLEUR')) {
        newRole = MemberRole.commissaire;
      }

      final old = members[memberIndex];
      members[memberIndex] = old.copyWith(
        role: newRole,
        roleAssignedBy: assignedBy,
        roleAssignedDate: DateTime.now(),
      );

      if (tontines.isNotEmpty) {
        tontines[0] = tontines[0].copyWith(members: members);
      }
    }
    return true;
  }

  /// Action : Enregistrer une cotisation (écriture en base puis relecture).
  Future<bool> recordPayment(TransactionEntity txn, {required int adhesionId, int? echeanceId, int? reunionId}) async {
    final blocked = contributionBlockReason(adhesionId);
    if (blocked != null) {
      lastSyncError = blocked;
      return false;
    }
    final response = await _api.post('/api/finances/cotisations/', {
      'adhesion_id': adhesionId,
      'montant': txn.amount.toInt(),
      'mode': switch (txn.paymentMethod) {
        PaymentMethod.especes => 'ESPECES',
        PaymentMethod.virement => 'VIREMENT',
        // §7.1 : modes directs auto-validés par le backend.
        PaymentMethod.mtnMoMo => 'MTN_MOMO',
        PaymentMethod.orangeMoney => 'ORANGE_MONEY',
      },
      'nature': 'ORDINAIRE',
      'referencePaiement': txn.reference,
      if (echeanceId != null) 'echeance_id': echeanceId,
      if (reunionId != null) 'reunion_id': reunionId,
      'enregistreePar_id': currentUserAdhesionIdFor(adhesionId) ?? adhesionId,
      'saisieDifferee': false,
    });
    if (!response.isOk) {
      lastSyncError = response.message;
      return false;
    }
    await syncFromBackend();
    return true;
  }

  /// Message de blocage si le membre a des pénalités impayées (`peutCotiser: false`).
  String? contributionBlockReason(int adhesionId) {
    for (final t in tontines) {
      for (final m in t.members) {
        if (numericId(m.id) == adhesionId && !m.canContribute) {
          return 'Cotisation bloquée : ${m.fullName} a ${m.unpaidPenaltiesCount} '
              'pénalité(s) impayée(s) (${m.unpaidPenaltiesAmount.toInt()} FCFA). '
              'Soldez-les avant de cotiser.';
        }
      }
    }
    return null;
  }

  /// Action : Valider une cotisation en espèces (Trésorier / Président).
  Future<bool> validateCotisation({required int cotisationId, int? valideurAdhesionId}) async {
    final valideur = valideurAdhesionId ?? currentUserAdhesionId;
    if (valideur == null) return false;
    final response = await _api.post(
      '/api/finances/cotisations/$cotisationId/valider/',
      {'valideur_adhesion_id': valideur},
    );
    if (!response.isOk) return false;
    await syncFromBackend();
    return true;
  }

  DistributionEntity? _distById(String id) {
    for (final d in distributions) {
      if (d.id == id) return d;
    }
    return null;
  }

  int? _tontineIdOfDistribution(DistributionEntity d) => numericId(d.tontineId);

  /// Président / Trésorier : exécute la distribution (POST .../executer/).
  Future<bool> signDistribution({
    required String distributionId,
    required UserEntity performedByUser,
    bool compenserDettes = false,
  }) async {
    final dist = _distById(distributionId);
    if (dist == null) return false;
    if (!performedByUser.isPresident && !performedByUser.isTreasurer) return false;

    if (dist.status == DistributionStatus.distribuee) {
      lastSyncError = 'Ce membre a déjà encaissé pour ce tour. Impossible d’encaisser deux fois.';
      return false;
    }

    final tid = _tontineIdOfDistribution(dist);
    if (tid != null) {
      final tDistributions = distributions.where((d) => numericId(d.tontineId) == tid).toList();
      for (final other in tDistributions) {
        if (other.turnNumber < dist.turnNumber && other.status != DistributionStatus.distribuee) {
          lastSyncError = 'Action refusée : Ce n\'est pas encore le tour de ${dist.beneficiaryName} (Tour #${dist.turnNumber}). Le Tour #${other.turnNumber} (${other.beneficiaryName}) doit être distribué en premier.';
          return false;
        }
      }
    }

    final numId = numericId(distributionId);
    final executeur = adhesionIdIn(_tontineIdOfDistribution(dist)) ?? currentUserAdhesionId;
    if (numId == null || executeur == null) return false;
    final response = await _api.post('/api/finances/distributions/$numId/executer/', {
      'executeur_adhesion_id': executeur,
      'montant': dist.netAmount.toInt(),
      'preuve': 'Exécution par ${performedByUser.fullName}',
      // §5.6 : déduit cotisations impayées, pénalités et échéances de prêt avant versement.
      'compenserDettes': compenserDettes,
    });
    if (!response.isOk) {
      lastSyncError = response.message;
      return false;
    }
    await syncFromBackend();
    return true;
  }

  /// Bénéficiaire : confirme la réception (POST .../confirmer/).
  Future<bool> confirmDistribution(String distributionId) async {
    final dist = _distById(distributionId);
    if (dist == null) return false;
    final numId = numericId(distributionId);
    final me = adhesionIdIn(_tontineIdOfDistribution(dist)) ?? currentUserAdhesionId;
    if (numId == null || me == null) return false;
    final response = await _api.post(
      '/api/finances/distributions/$numId/confirmer/',
      {'beneficiaire_adhesion_id': me},
    );
    if (!response.isOk) {
      lastSyncError = response.message;
      return false;
    }
    await syncFromBackend();
    return true;
  }

  Future<ApiResponse> _act(String path, Map<String, dynamic> body) async {
    final response = await _api.post(path, body);
    if (response.isOk) await syncFromBackend();
    return response;
  }

  // ----- Ordre de passage (contrat §1.9) -----
  /// Permute deux tours : POST .../ordre-passage/permuter/
  Future<ApiResponse> swapTurns(int cycleId, {required int rankSource, required int rankTarget}) {
    return _act('/api/tontines/cycles/$cycleId/ordre-passage/permuter/', {
      'rang_source': rankSource,
      'rang_cible': rankTarget,
    });
  }

  /// Ordre personnalisé / mise à jour des dates : PUT .../ordre-passage/
  Future<ApiResponse> saveTurnOrder(int cycleId, List<Map<String, dynamic>> ordres) async {
    final response = await _api.put('/api/tontines/cycles/$cycleId/ordre-passage/', {'ordres': ordres});
    if (response.isOk) await syncFromBackend();
    return response;
  }

  /// Régénère l'ordre : POST .../ordre-passage/ (`methode`: TIRAGE_SORT).
  Future<ApiResponse> regenerateTurnOrder(int cycleId, {String methode = 'TIRAGE_SORT'}) {
    return _act('/api/tontines/cycles/$cycleId/ordre-passage/', {'methode': methode});
  }

  // ----- Pénalités (contrat §3.5) -----
  Future<ApiResponse> fetchPenalties(int tontineId) => _api.get('/api/tontines/$tontineId/penalites/');

  /// Règle une pénalité : POST /api/tontines/<id>/penalites/<id>/payer/
  /// (débloque `peutCotiser` du membre, d'où la resynchronisation).
  Future<ApiResponse> payPenalty({required int tontineId, required int penaltyId}) {
    return _act('/api/tontines/$tontineId/penalites/$penaltyId/payer/', const {});
  }

  // ----- Réunions (contrat §4.8) -----
  Future<ApiResponse> createMeeting({
    required int tontineId,
    required DateTime date,
    required String lieu,
    String ordreDuJour = '',
  }) {
    return _act('/api/tontines/$tontineId/reunions/', {
      'date': date.toIso8601String().split('.').first,
      'lieu': lieu,
      'mode': 'PHYSIQUE',
      'lienVisio': '',
      'ordreDuJour': ordreDuJour,
    });
  }

  // ----- Prêts (contrat §6) -----
  Future<ApiResponse> decideLoan(String loanId, {required bool approve, String motif = ''}) {
    final me = currentUserAdhesionId;
    return _act('/api/prets/demandes/${numericId(loanId)}/decider/', {
      'decideur_adhesion_id': me,
      'decision': approve ? 'APPROUVE' : 'REJETE',
      'motif': motif.isEmpty ? (approve ? 'Demande conforme' : 'Demande refusée') : motif,
    });
  }

  Future<ApiResponse> disburseLoan(String loanId, {required double amount, required double rate, String typeTaux = 'FIXE'}) {
    return _act('/api/prets/demandes/${numericId(loanId)}/decaisser/', {
      'caisse_id': caisseIdFor(primaryTontineId, 'PRETS') ?? primaryCaisseId,
      'montantAccorde': amount.toInt(),
      'tauxInteret': rate.toStringAsFixed(2),
      'typeTaux': typeTaux,
    });
  }

  Future<ApiResponse> repayLoan(String loanId, {required double amount}) {
    return _act('/api/prets/${numericId(loanId)}/rembourser/', {
      'montant': amount.toInt(),
      'reference': 'REM-${DateTime.now().millisecondsSinceEpoch}',
    });
  }

  // ----- Entraide (contrat §7) -----
  Future<ApiResponse> validateAid(String aidId, {required bool approve}) {
    return _act('/api/entraide/evenements/${numericId(aidId)}/valider/', {
      'decision': approve ? 'APPROUVE' : 'REJETE',
    });
  }

  Future<ApiResponse> contributeAid(String aidId, {required double amount}) {
    return _act('/api/entraide/evenements/${numericId(aidId)}/contribuer/', {
      'adhesion_id': currentUserAdhesionId,
      'montant': amount.toInt(),
    });
  }

  Future<ApiResponse> disburseAid(String aidId, {required double amount, String proof = 'Décaissement validé'}) {
    return _act('/api/entraide/evenements/${numericId(aidId)}/decaisser-aide/', {
      'montant': amount.toInt(),
      'preuve': proof,
    });
  }

  // ----- Caisse (contrat §5.4-5.5) -----
  Future<ApiResponse> reconcileCaisse(double soldeReel) {
    return _act('/api/finances/caisses/$primaryCaisseId/rapprochements/', {
      'adhesion_id': currentUserAdhesionId,
      'soldeReel': soldeReel.toInt(),
    });
  }

  // ==================================================================
  // Contrat API : cycles, clôtures, départs, compensations, pénalités,
  // WhatsApp, supervision. Les messages d'erreur métier du serveur
  // (HTTP 400/403) sont renvoyés tels quels dans `ApiResponse.message`.
  // ==================================================================

  // ----- Cycles de cotisation (contrat §4.5) -----
  /// Démarre ou personnalise un cycle : POST /api/tontines/<id>/cycles/
  /// (dateDebut, dateFin, frequence, intervalleJours, datesEcheances,
  /// nombreTours, typeCotisation, montantCotisation, partsParMembre).
  Future<ApiResponse> startCycle(int tontineId, Map<String, dynamic> body) {
    return _act('/api/tontines/$tontineId/cycles/', body);
  }

  /// Détails d'un cycle : GET /api/tontines/cycles/<id>/
  Future<ApiResponse> fetchCycle(int cycleId) => _api.get('/api/tontines/cycles/$cycleId/');

  /// Met à jour `statut`, `dateFin` ou `datesEcheances` : PUT /api/tontines/cycles/<id>/
  Future<ApiResponse> updateCycle(int cycleId, Map<String, dynamic> body) async {
    final response = await _api.put('/api/tontines/cycles/$cycleId/', body);
    if (response.isOk) await syncFromBackend();
    return response;
  }

  /// Clôture un cycle (refusée en 400 si un membre actif n'a pas bénéficié).
  Future<ApiResponse> closeCycle(int cycleId) =>
      _act('/api/tontines/cycles/$cycleId/cloturer/', const {});

  /// Clôture définitivement une tontine (même règle stricte).
  Future<ApiResponse> closeTontine(int tontineId) =>
      _act('/api/tontines/$tontineId/cloturer/', const {});

  /// Échéances d'un cycle : GET /api/tontines/cycles/<id>/echeances/
  Future<ApiResponse> fetchEcheances(int cycleId) =>
      _api.get('/api/tontines/cycles/$cycleId/echeances/');

  // ----- Départ / démission d'un membre (contrat §4.5.4) -----
  Future<ApiResponse> simulateDeparture(int tontineId, int adhesionId) =>
      _api.post('/api/tontines/$tontineId/membres/$adhesionId/depart/simuler/', const {});

  Future<ApiResponse> confirmDeparture(
    int tontineId,
    int adhesionId, {
    required String modePaiement,
    required String reference,
    required String motif,
  }) {
    return _act('/api/tontines/$tontineId/membres/$adhesionId/depart/quitter/', {
      'modePaiement': modePaiement,
      'reference': reference,
      'motif': motif,
    });
  }

  // ----- Compensations de dettes (contrat §5.7) -----
  Future<ApiResponse> simulateCompensation(int distributionId) =>
      _api.post('/api/finances/compensations/simuler/', {'distribution_id': distributionId});

  Future<ApiResponse> executeCompensation(
    int distributionId, {
    bool deduireCotisations = true,
    bool deduirePenalites = true,
    bool deduirePrets = true,
    String justificatif = 'Compensation automatique sur distribution',
  }) {
    return _act('/api/finances/compensations/executer/', {
      'distribution_id': distributionId,
      'deduireCotisations': deduireCotisations,
      'deduirePenalites': deduirePenalites,
      'deduirePrets': deduirePrets,
      'justificatif': justificatif,
    });
  }

  Future<ApiResponse> fetchCompensations({int? tontineId, int? adhesionId, int? distributionId}) {
    return _api.get('/api/finances/compensations/', queryParams: {
      if (tontineId != null) 'tontine_id': '$tontineId',
      if (adhesionId != null) 'adhesion_id': '$adhesionId',
      if (distributionId != null) 'distribution_id': '$distributionId',
    });
  }

  // ----- Répartition de la caisse de pénalités (contrat §5.8) -----
  Future<ApiResponse> simulatePenaltyShare(int tontineId, {int? beneficiaries}) {
    return _api.post(
      '/api/finances/caisses/tontine/$tontineId/penalites/repartir/simuler/',
      {if (beneficiaries != null) 'nombreBeneficiaires': beneficiaries},
    );
  }

  Future<ApiResponse> executePenaltyShare(int tontineId, {required int beneficiaries, required String justificatif}) {
    return _act('/api/finances/caisses/tontine/$tontineId/penalites/repartir/', {
      'nombreBeneficiaires': beneficiaries,
      'justificatif': justificatif,
    });
  }

  // ----- Notifications WhatsApp (contrat §4.14) -----
  // Réservées à SECRETAIRE / PRESIDENT / FONDATEUR (403 sinon : le message
  // du serveur est affiché tel quel).
  Future<ApiResponse> whatsappContributionReminder(int echeanceId) =>
      _api.post('/api/tontines/echeances/$echeanceId/rappel-whatsapp/', const {});

  Future<ApiResponse> whatsappCycleReminders(int cycleId) =>
      _api.post('/api/tontines/cycles/$cycleId/rappels-whatsapp/', const {});

  Future<ApiResponse> whatsappMeetingConvocation(int meetingId, {String? note}) =>
      _api.post('/api/tontines/reunions/$meetingId/notifier-whatsapp/',
          {if (note != null && note.isNotEmpty) 'note': note});

  Future<ApiResponse> whatsappAnnouncement(int announcementId) =>
      _api.post('/api/tontines/annonces/$announcementId/diffuser-whatsapp/', const {});

  Future<ApiResponse> whatsappTurnAlert(int cycleId, int adhesionId) =>
      _api.post('/api/tontines/cycles/$cycleId/ordre-passage/$adhesionId/notifier-whatsapp/', const {});

  /// Journal des notifications : GET /api/tontines/<id>/notifications/?canal=&type=
  Future<ApiResponse> fetchTontineNotifications(int tontineId, {String? canal, String? type}) {
    return _api.get('/api/tontines/$tontineId/notifications/', queryParams: {
      if (canal != null && canal.isNotEmpty) 'canal': canal,
      if (type != null && type.isNotEmpty) 'type': type,
    });
  }

  // ----- Comptes (contrat §3) -----
  /// Notifications de l'utilisateur : GET /api/comptes/notifications/
  Future<ApiResponse> fetchMyNotifications() => _api.get('/api/comptes/notifications/');

  /// Supervision Super Admin : GET /api/comptes/admin/presidents/
  Future<ApiResponse> fetchPlatformPresidents() => _api.get('/api/comptes/admin/presidents/');

  /// Réunions du serveur (id numérique) d'une tontine, pour les convocations.
  Future<ApiResponse> fetchMeetings(int tontineId) => _api.get('/api/tontines/$tontineId/reunions/');

  /// Annonces d'une tontine, pour la diffusion WhatsApp.
  Future<ApiResponse> fetchAnnouncements(int tontineId) => _api.get('/api/tontines/$tontineId/annonces/');


  /// Action : Émargement et présence en réunion
  Future<bool> updateMeetingAttendance({
    required String meetingId,
    required int memberIndex,
    required bool isPresent,
    double cashAmount = 0,
  }) async {
    final mIdx = meetings.indexWhere((m) => m.id == meetingId);
    if (mIdx == -1 || memberIndex >= meetings[mIdx].attendanceList.length) {
      return false;
    }
    final currentAttendance = meetings[mIdx].attendanceList[memberIndex];
    final meetingNumber = int.tryParse(meetingId.replaceAll(RegExp(r'[^0-9]'), ''));
    final adhesionNumber = int.tryParse(
      currentAttendance.memberId.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    if (meetingNumber == null || adhesionNumber == null) return false;

    final response = await _api.post(
      '/api/tontines/reunions/$meetingNumber/presences/',
      {
        'adhesion_id': adhesionNumber,
        'statut': isPresent ? 'PRESENT' : 'ABSENT',
        'modeParticipation': 'PHYSIQUE',
      },
    );
    if (!response.isOk) return false;

    meetings[mIdx].attendanceList[memberIndex] = currentAttendance.copyWith(
      isPresent: isPresent,
      cashContributed:
          cashAmount > 0 ? cashAmount : currentAttendance.cashContributed,
      cashReceiptIssued: cashAmount > 0,
    );
    return true;
  }
}
