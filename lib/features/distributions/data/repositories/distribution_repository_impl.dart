import '../../domain/entities/distribution.dart';
import '../../domain/repositories/distribution_repository.dart';
import '../datasources/distribution_local_data_source.dart';

class DistributionRepositoryImpl implements DistributionRepository {
  const DistributionRepositoryImpl(this._dataSource);

  final DistributionLocalDataSource _dataSource;

  @override
  Future<List<Distribution>> getDistributions() => _dataSource.getDistributions();

}
