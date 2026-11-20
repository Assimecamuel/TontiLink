import '../../../../core/usecases/usecase.dart';
import '../entities/tontine.dart';
import '../repositories/tontine_repository.dart';

class GetTontines implements UseCase<List<Tontine>, NoParams> {
  const GetTontines(this._repository);

  final TontineRepository _repository;

  @override
  Future<List<Tontine>> call(NoParams params) => _repository.getTontines();
}
