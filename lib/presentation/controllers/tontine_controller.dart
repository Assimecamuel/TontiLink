import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/tontine_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/distribution_entity.dart';
import '../../domain/entities/caisse_entity.dart';
import '../../domain/entities/loan_and_aid_entity.dart';
import '../../domain/entities/meeting_entity.dart';
import '../../domain/repositories/tontine_repository.dart';
import '../../data/repositories/tontine_repository_impl.dart';

class TontineController extends ChangeNotifier {
  static final TontineController _instance = TontineController._internal();
  factory TontineController() => _instance;

  final TontineRepository _repository = TontineRepositoryImpl();

  TontineEntity? _selectedTontine;
  bool _isCreatingTontine = false;

  TontineController._internal();

  TontineEntity? get selectedTontine => _selectedTontine;
  bool get isCreatingTontine => _isCreatingTontine;

  List<TontineEntity> get tontines => _repository.getTontines();
  List<TransactionEntity> get transactions => _repository.getTransactions();
  List<DistributionEntity> get distributions => _repository.getDistributions();
  CaisseSummaryEntity get caisseSummary => _repository.getCaisseSummary();
  List<LoanEntity> get loans => _repository.getLoans();
  List<AidEventEntity> get aidEvents => _repository.getAidEvents();
  List<MeetingEntity> get meetings => _repository.getMeetings();

  void selectTontine(TontineEntity? tontine) {
    _selectedTontine = tontine;
    _isCreatingTontine = false;
    notifyListeners();
  }

  void startCreateTontine() {
    _isCreatingTontine = true;
    _selectedTontine = null;
    notifyListeners();
  }

  void cancelCreateTontine() {
    _isCreatingTontine = false;
    notifyListeners();
  }

  void addTontine(TontineEntity tontine) {
    _repository.addTontine(tontine);
    _selectedTontine = tontine;
    _isCreatingTontine = false;
    notifyListeners();
  }

  /// Modification statutaire d'un rôle de membre :
  /// Seul le Président de la tontine est habilité selon le Cahier des charges
  Future<bool> changeMemberRole({
    required String tontineId,
    required String memberId,
    required MemberRole newRole,
    required UserEntity performedByUser,
    String reason = 'Décision statutaire de l\'Assemblée Générale',
  }) async {
    if (!performedByUser.isPresident) {
      return false;
    }

    final success = await _repository.updateMemberRole(
      tontineId: tontineId,
      memberId: memberId,
      newRole: newRole,
      performedByUser: performedByUser,
      reason: reason,
    );

    if (success) {
      if (_selectedTontine != null && _selectedTontine!.id == tontineId) {
        _selectedTontine = _repository.getTontineById(tontineId);
      }
      notifyListeners();
    }
    return success;
  }

  List<MemberEntity> getMembersForTontine(String tontineId) {
    return _repository.getMembersForTontine(tontineId);
  }

  void recordPayment(TransactionEntity txn) {
    _repository.recordTransaction(txn);
    notifyListeners();
  }

  Future<bool> signDistribution(String distId, UserEntity user) async {
    final success = await _repository.signDistribution(
      distributionId: distId,
      performedByUser: user,
    );
    if (success) {
      notifyListeners();
    }
    return success;
  }

  void updateMeetingAttendance(String meetingId, int index, bool isPresent, double cash) {
    _repository.updateMeetingAttendance(
      meetingId: meetingId,
      memberIndex: index,
      isPresent: isPresent,
      cashAmount: cash,
    );
    notifyListeners();
  }

  void addCaisseEntry(CaisseEntryEntity entry) {
    _repository.addCaisseEntry(entry);
    notifyListeners();
  }
}
