import '../../../../core/usecases/usecase.dart';
import '../entities/loan_and_aid.dart';
import '../repositories/prets_entraide_repository.dart';

class GetAidEvents implements UseCase<List<AidEvent>, NoParams> {
  const GetAidEvents(this._repository);

  final PretsEntraideRepository _repository;

  @override
  Future<List<AidEvent>> call(NoParams params) => _repository.getAidEvents();
}
