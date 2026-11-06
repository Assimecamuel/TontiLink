import '../../domain/entities/user_entity.dart';
import '../../domain/entities/tontine_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/distribution_entity.dart';
import '../../domain/entities/caisse_entity.dart';
import '../../domain/entities/loan_and_aid_entity.dart';
import '../../domain/entities/meeting_entity.dart';
import '../../domain/repositories/tontine_repository.dart';
import '../datasources/local_tonti_datasource.dart';

class TontineRepositoryImpl implements TontineRepository {
  final LocalTontiDataSource _dataSource = LocalTontiDataSource();

  @override
  List<TontineEntity> getTontines() => _dataSource.tontines;

  @override
  TontineEntity? getTontineById(String id) {
    try {
      return _dataSource.tontines.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void addTontine(TontineEntity tontine) {
    _dataSource.tontines.insert(0, tontine);
  }

  @override
  Future<bool> updateMemberRole({
    required String tontineId,
    required String memberId,
    required MemberRole newRole,
    required UserEntity performedByUser,
    String reason = 'Décision statutaire',
  }) async {
    // VÉRIFICATION DE SÉCURITÉ CONFORME AU CAHIER DES CHARGES :
    // SEUL LE PRÉSIDENT A LE DROIT DE MODIFIER LES RÔLES DES MEMBRES !
    if (!performedByUser.isPresident) {
      return false; // Interdit par le règlement intérieur
    }

    // 1. Envoyer au backend avant de mettre à jour l'état affiché.
    final adhId = int.tryParse(memberId.replaceAll(RegExp(r'[^0-9]'), ''));
    if (adhId == null) return false;
    String roleStr = 'MEMBRE';
    switch (newRole) {
      case MemberRole.president:
        roleStr = 'PRESIDENT';
        break;
      case MemberRole.tresorier:
        roleStr = 'TRESORIER';
        break;
      case MemberRole.secretaire:
        roleStr = 'SECRETAIRE';
        break;
      case MemberRole.commissaire:
        roleStr = 'COMMISSAIRE';
        break;
      case MemberRole.membre:
        roleStr = 'MEMBRE';
        break;
    }
    final updatedOnServer = await _dataSource.assignMemberRole(
      targetAdhesionId: adhId,
      roleName: roleStr,
      memberId: memberId,
      assignedBy: '${performedByUser.fullName} (Président)',
      tontineId: int.tryParse(tontineId.replaceAll(RegExp(r'[^0-9]'), '')),
    );
    if (!updatedOnServer) return false;

    // Mettre à jour dans le registre général des membres
    final memberIndex = _dataSource.members.indexWhere((m) => m.id == memberId);
    if (memberIndex != -1) {
      final old = _dataSource.members[memberIndex];
      _dataSource.members[memberIndex] = old.copyWith(
        role: newRole,
        roleAssignedBy: '${performedByUser.fullName} (Président)',
        roleAssignedDate: DateTime.now(),
      );
    }

    // 2. Mettre à jour dans la tontine concernée
    final tontineIndex = _dataSource.tontines.indexWhere((t) => t.id == tontineId);
    if (tontineIndex != -1) {
      final t = _dataSource.tontines[tontineIndex];
      final updatedMembers = t.members.map((m) {
        if (m.id == memberId) {
          return m.copyWith(
            role: newRole,
            roleAssignedBy: '${performedByUser.fullName} (Président)',
            roleAssignedDate: DateTime.now(),
          );
        }
        return m;
      }).toList();

      _dataSource.tontines[tontineIndex] = t.copyWith(members: updatedMembers);
    }

    return true;
  }

  @override
  List<MemberEntity> getMembersForTontine(String tontineId) {
    final t = getTontineById(tontineId);
    if (t != null && t.members.isNotEmpty) {
      return t.members;
    }
    return _dataSource.members;
  }

  @override
  List<TransactionEntity> getTransactions() => _dataSource.transactions;

  @override
  void recordTransaction(TransactionEntity transaction) {
    // L'adhésion du membre est retrouvée dans la tontine concernée.
    for (final t in _dataSource.tontines) {
      if (t.name != transaction.tontineName) continue;
      for (final m in t.members) {
        if (m.fullName == transaction.memberName) {
          final adhesionId = LocalTontiDataSource.numericId(m.id);
          if (adhesionId != null) {
            _dataSource.recordPayment(transaction, adhesionId: adhesionId);
          }
          return;
        }
      }
    }
  }

  @override
  List<DistributionEntity> getDistributions() => _dataSource.distributions;

  @override
  Future<bool> signDistribution({
    required String distributionId,
    required UserEntity performedByUser,
  }) async {
    if (!performedByUser.isPresident && !performedByUser.isTreasurer) {
      return false;
    }
    return _dataSource.signDistribution(
      distributionId: distributionId,
      performedByUser: performedByUser,
    );
  }

  @override
  CaisseSummaryEntity getCaisseSummary() => _dataSource.caisseSummary;

  @override
  void addCaisseEntry(CaisseEntryEntity entry) {
    _dataSource.caisseSummary.recentEntries.insert(0, entry);
  }

  @override
  List<LoanEntity> getLoans() => _dataSource.loans;

  @override
  void requestLoan(LoanEntity loan) {
    _dataSource.loans.insert(0, loan);
  }

  @override
  List<AidEventEntity> getAidEvents() => _dataSource.aidEvents;

  @override
  void requestAid(AidEventEntity aid) {
    _dataSource.aidEvents.insert(0, aid);
  }

  @override
  List<MeetingEntity> getMeetings() => _dataSource.meetings;

  @override
  void updateMeetingAttendance({
    required String meetingId,
    required int memberIndex,
    required bool isPresent,
    double cashAmount = 0,
  }) {
    _dataSource.updateMeetingAttendance(
      meetingId: meetingId,
      memberIndex: memberIndex,
      isPresent: isPresent,
      cashAmount: cashAmount,
    );
  }
}
