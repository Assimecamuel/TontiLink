import 'package:flutter/foundation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/member.dart';
import '../../domain/usecases/get_members.dart';

class MembersController extends ChangeNotifier {
  MembersController({required GetMembers getMembers}) : _getMembers = getMembers;

  final GetMembers _getMembers;

  List<Member> _members = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _members = await _getMembers(const NoParams());
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
