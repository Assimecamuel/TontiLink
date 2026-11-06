import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._dataSource);

  final TransactionLocalDataSource _dataSource;

  @override
  Future<List<Transaction>> getTransactions() => _dataSource.getTransactions();

  @override
  Future<void> recordTransaction(Transaction item) => _dataSource.recordTransaction(item);

}
