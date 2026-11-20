import 'package:flutter/foundation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/loan_and_aid.dart';
import '../../domain/usecases/get_loans.dart';
import '../../domain/usecases/get_aid_events.dart';

class PretsEntraideController extends ChangeNotifier {
  PretsEntraideController({required GetLoans getLoans, required GetAidEvents getAidEvents}) : _getLoans = getLoans, _getAidEvents = getAidEvents;

  final GetLoans _getLoans;
  final GetAidEvents _getAidEvents;

  List<Loan> _loans = const [];
  List<AidEvent> _aidEvents = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Loan> get loans => _loans;
  List<AidEvent> get aidEvents => _aidEvents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _loans = await _getLoans(const NoParams());
      _aidEvents = await _getAidEvents(const NoParams());
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
