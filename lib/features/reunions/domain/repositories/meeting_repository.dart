import '../entities/meeting.dart';

abstract class MeetingRepository {
  Future<List<Meeting>> getMeetings();
}
