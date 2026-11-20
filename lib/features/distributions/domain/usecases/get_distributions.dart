import '../../../../core/usecases/usecase.dart';
import '../entities/distribution.dart';
import '../repositories/distribution_repository.dart';

class GetDistributions implements UseCase<List<Distribution>, NoParams> {
  const GetDistributions(this._repository);

  final DistributionRepository _repository;

  @override
  Future<List<Distribution>> call(NoParams params) => _repository.getDistributions();
}
