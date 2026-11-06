import '../../domain/entities/tontine.dart';
import '../../domain/repositories/tontine_repository.dart';
import '../datasources/tontine_local_data_source.dart';

class TontineRepositoryImpl implements TontineRepository {
  const TontineRepositoryImpl(this._dataSource);

  final TontineLocalDataSource _dataSource;

  @override
  Future<List<Tontine>> getTontines() => _dataSource.getTontines();

  @override
  Future<void> addTontine(Tontine item) => _dataSource.addTontine(item);

}
