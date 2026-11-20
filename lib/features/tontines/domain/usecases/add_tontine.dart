import '../../../../core/usecases/usecase.dart';
import '../entities/tontine.dart';
import '../repositories/tontine_repository.dart';

class AddTontine implements UseCase<void, Tontine> {
  const AddTontine(this._repository);

  final TontineRepository _repository;

  @override
  Future<void> call(Tontine params) => _repository.addTontine(params);
}
