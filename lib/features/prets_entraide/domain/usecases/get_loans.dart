import '../../../../core/usecases/usecase.dart';
import '../entities/loan_and_aid.dart';
import '../repositories/prets_entraide_repository.dart';

class GetLoans implements UseCase<List<Loan>, NoParams> {
  const GetLoans(this._repository);

  final PretsEntraideRepository _repository;

  @override
  Future<List<Loan>> call(NoParams params) => _repository.getLoans();
}
