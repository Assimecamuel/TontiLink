import '../../domain/entities/loan_and_aid.dart';
import '../../domain/repositories/prets_entraide_repository.dart';
import '../datasources/prets_entraide_local_data_source.dart';

class PretsEntraideRepositoryImpl implements PretsEntraideRepository {
  const PretsEntraideRepositoryImpl(this._dataSource);

  final PretsEntraideLocalDataSource _dataSource;

  @override
  Future<List<Loan>> getLoans() => _dataSource.getLoans();

  @override
  Future<List<AidEvent>> getAidEvents() => _dataSource.getAidEvents();

}
