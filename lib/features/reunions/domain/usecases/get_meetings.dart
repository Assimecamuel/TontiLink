import '../../../../core/usecases/usecase.dart';
import '../entities/meeting.dart';
import '../repositories/meeting_repository.dart';

class GetMeetings implements UseCase<List<Meeting>, NoParams> {
  const GetMeetings(this._repository);

  final MeetingRepository _repository;

  @override
  Future<List<Meeting>> call(NoParams params) => _repository.getMeetings();
}
