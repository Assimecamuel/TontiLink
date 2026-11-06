import '../../../../core/usecases/usecase.dart';
import '../entities/caisse_summary.dart';
import '../repositories/caisse_repository.dart';

class GetCaisseSummary implements UseCase<CaisseSummary, NoParams> {
  const GetCaisseSummary(this._repository);

  final CaisseRepository _repository;

  @override
  Future<CaisseSummary> call(NoParams params) => _repository.getCaisseSummary();
}
