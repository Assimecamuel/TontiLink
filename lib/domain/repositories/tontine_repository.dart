import '../entities/user_entity.dart';
import '../entities/tontine_entity.dart';
import '../entities/member_entity.dart';
import '../entities/transaction_entity.dart';
import '../entities/distribution_entity.dart';
import '../entities/caisse_entity.dart';
import '../entities/loan_and_aid_entity.dart';
import '../entities/meeting_entity.dart';

abstract class TontineRepository {
  List<TontineEntity> getTontines();
  TontineEntity? getTontineById(String id);
  void addTontine(TontineEntity tontine);

  /// Attribution et modification de rôle : Strictement réservé au Président de la tontine
  Future<bool> updateMemberRole({
    required String tontineId,
    required String memberId,
    required MemberRole newRole,
    required UserEntity performedByUser,
    String reason,
  });

  List<MemberEntity> getMembersForTontine(String tontineId);

  List<TransactionEntity> getTransactions();
  void recordTransaction(TransactionEntity transaction);

  List<DistributionEntity> getDistributions();
  Future<bool> signDistribution({
    required String distributionId,
    required UserEntity performedByUser,
  });

  CaisseSummaryEntity getCaisseSummary();
  void addCaisseEntry(CaisseEntryEntity entry);

  List<LoanEntity> getLoans();
  void requestLoan(LoanEntity loan);

  List<AidEventEntity> getAidEvents();
  void requestAid(AidEventEntity aid);

  List<MeetingEntity> getMeetings();
  void updateMeetingAttendance({
    required String meetingId,
    required int memberIndex,
    required bool isPresent,
    double cashAmount,
  });
}
