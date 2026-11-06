import 'datasources/local_tonti_datasource.dart';
import '../domain/entities/tontine_entity.dart';
import '../domain/entities/member_entity.dart';
import '../domain/entities/transaction_entity.dart';
import '../domain/entities/distribution_entity.dart';
import '../domain/entities/caisse_entity.dart';
import '../domain/entities/loan_and_aid_entity.dart';
import '../domain/entities/meeting_entity.dart';

class MockTontiData {
  static List<TontineEntity> get tontines => LocalTontiDataSource().tontines;
  static List<MemberEntity> get members => LocalTontiDataSource().members;
  static List<TransactionEntity> get transactions => LocalTontiDataSource().transactions;
  static List<DistributionEntity> get distributions => LocalTontiDataSource().distributions;
  static CaisseSummaryEntity get caisseSummary => LocalTontiDataSource().caisseSummary;
  static List<LoanEntity> get loans => LocalTontiDataSource().loans;
  static List<AidEventEntity> get aidEvents => LocalTontiDataSource().aidEvents;
  static List<MeetingEntity> get meetings => LocalTontiDataSource().meetings;
}
