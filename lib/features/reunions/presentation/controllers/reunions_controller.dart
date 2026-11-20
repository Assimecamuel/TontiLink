import 'package:flutter/foundation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/usecases/get_meetings.dart';

class ReunionsController extends ChangeNotifier {
  ReunionsController({required GetMeetings getMeetings}) : _getMeetings = getMeetings;

  final GetMeetings _getMeetings;

  List<Meeting> _meetings = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Meeting> get meetings => _meetings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _meetings = await _getMeetings(const NoParams());
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
