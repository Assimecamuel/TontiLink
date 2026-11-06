import 'features/caisse/data/datasources/caisse_local_data_source.dart';
import 'features/caisse/data/repositories/caisse_repository_impl.dart';
import 'features/caisse/domain/usecases/get_caisse_summary.dart';
import 'features/caisse/presentation/controllers/caisse_controller.dart';
import 'features/cotisations/data/datasources/transaction_local_data_source.dart';
import 'features/cotisations/data/repositories/transaction_repository_impl.dart';
import 'features/cotisations/domain/usecases/get_transactions.dart';
import 'features/cotisations/domain/usecases/record_transaction.dart';
import 'features/cotisations/presentation/controllers/cotisations_controller.dart';
import 'features/distributions/data/datasources/distribution_local_data_source.dart';
import 'features/distributions/data/repositories/distribution_repository_impl.dart';
import 'features/distributions/domain/usecases/get_distributions.dart';
import 'features/distributions/presentation/controllers/distributions_controller.dart';
import 'features/members/data/datasources/member_local_data_source.dart';
import 'features/members/data/repositories/member_repository_impl.dart';
import 'features/members/domain/usecases/get_members.dart';
import 'features/members/presentation/controllers/members_controller.dart';
import 'features/prets_entraide/data/datasources/prets_entraide_local_data_source.dart';
import 'features/prets_entraide/data/repositories/prets_entraide_repository_impl.dart';
import 'features/prets_entraide/domain/usecases/get_aid_events.dart';
import 'features/prets_entraide/domain/usecases/get_loans.dart';
import 'features/prets_entraide/presentation/controllers/prets_entraide_controller.dart';
import 'features/reunions/data/datasources/meeting_local_data_source.dart';
import 'features/reunions/data/repositories/meeting_repository_impl.dart';
import 'features/reunions/domain/usecases/get_meetings.dart';
import 'features/reunions/presentation/controllers/reunions_controller.dart';
import 'features/tontines/data/datasources/tontine_local_data_source.dart';
import 'features/tontines/data/repositories/tontine_repository_impl.dart';
import 'features/tontines/domain/usecases/add_tontine.dart';
import 'features/tontines/domain/usecases/get_tontines.dart';
import 'features/tontines/presentation/controllers/tontines_controller.dart';

/// Conteneur d'injection de dépendances (manuel, sans package externe).
///
/// Assemble, pour chaque feature : DataSource -> Repository -> UseCases -> Controller.
/// Les écrans de la couche présentation ne connaissent que les controllers.
class InjectionContainer {
  InjectionContainer._();

  static final InjectionContainer instance = InjectionContainer._();

  bool _initialized = false;

  late final TontinesController tontinesController;
  late final MembersController membersController;
  late final CotisationsController cotisationsController;
  late final DistributionsController distributionsController;
  late final CaisseController caisseController;
  late final PretsEntraideController pretsEntraideController;
  late final ReunionsController reunionsController;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final tontinesRepository = TontineRepositoryImpl(TontineLocalDataSourceImpl());
    tontinesController = TontinesController(
      getTontines: GetTontines(tontinesRepository),
      addTontine: AddTontine(tontinesRepository),
    );

    final membersRepository = MemberRepositoryImpl(MemberLocalDataSourceImpl());
    membersController = MembersController(
      getMembers: GetMembers(membersRepository),
    );

    final cotisationsRepository = TransactionRepositoryImpl(TransactionLocalDataSourceImpl());
    cotisationsController = CotisationsController(
      getTransactions: GetTransactions(cotisationsRepository),
      recordTransaction: RecordTransaction(cotisationsRepository),
    );

    final distributionsRepository = DistributionRepositoryImpl(DistributionLocalDataSourceImpl());
    distributionsController = DistributionsController(
      getDistributions: GetDistributions(distributionsRepository),
    );

    final caisseRepository = CaisseRepositoryImpl(CaisseLocalDataSourceImpl());
    caisseController = CaisseController(
      getCaisseSummary: GetCaisseSummary(caisseRepository),
    );

    final pretsEntraideRepository = PretsEntraideRepositoryImpl(PretsEntraideLocalDataSourceImpl());
    pretsEntraideController = PretsEntraideController(
      getLoans: GetLoans(pretsEntraideRepository),
      getAidEvents: GetAidEvents(pretsEntraideRepository),
    );

    final reunionsRepository = MeetingRepositoryImpl(MeetingLocalDataSourceImpl());
    reunionsController = ReunionsController(
      getMeetings: GetMeetings(reunionsRepository),
    );
    await Future.wait([
      tontinesController.load(),
      membersController.load(),
      cotisationsController.load(),
      distributionsController.load(),
      caisseController.load(),
      pretsEntraideController.load(),
      reunionsController.load(),
    ]);
  }
}

/// Raccourci d'accès (service locator).
final InjectionContainer sl = InjectionContainer.instance;
