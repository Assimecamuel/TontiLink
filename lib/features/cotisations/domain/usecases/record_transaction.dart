import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class RecordTransaction implements UseCase<void, Transaction> {
  const RecordTransaction(this._repository);

  final TransactionRepository _repository;

  @override
  Future<void> call(Transaction params) => _repository.recordTransaction(params);
}
