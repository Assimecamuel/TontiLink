import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactions implements UseCase<List<Transaction>, NoParams> {
  const GetTransactions(this._repository);

  final TransactionRepository _repository;

  @override
  Future<List<Transaction>> call(NoParams params) => _repository.getTransactions();
}
