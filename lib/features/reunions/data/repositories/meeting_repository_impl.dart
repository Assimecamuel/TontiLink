import '../../domain/entities/meeting.dart';
import '../../domain/repositories/meeting_repository.dart';
import '../datasources/meeting_local_data_source.dart';

class MeetingRepositoryImpl implements MeetingRepository {
  const MeetingRepositoryImpl(this._dataSource);

  final MeetingLocalDataSource _dataSource;

  @override
  Future<List<Meeting>> getMeetings() => _dataSource.getMeetings();

}
