import '../../domain/entities/caisse_summary.dart';
import '../../domain/repositories/caisse_repository.dart';
import '../datasources/caisse_local_data_source.dart';

class CaisseRepositoryImpl implements CaisseRepository {
  const CaisseRepositoryImpl(this._dataSource);

  final CaisseLocalDataSource _dataSource;

  @override
  Future<CaisseSummary> getCaisseSummary() => _dataSource.getCaisseSummary();

}
