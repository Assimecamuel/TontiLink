import 'package:flutter/foundation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/tontine.dart';
import '../../domain/usecases/get_tontines.dart';
import '../../domain/usecases/add_tontine.dart';

class TontinesController extends ChangeNotifier {
  TontinesController({required GetTontines getTontines, required AddTontine addTontine}) : _getTontines = getTontines, _addTontine = addTontine;

  final GetTontines _getTontines;
  final AddTontine _addTontine;

  List<Tontine> _tontines = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Tontine> get tontines => _tontines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _tontines = await _getTontines(const NoParams());
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTontine(Tontine item) async {
    try {
      await _addTontine(item);
      _tontines = await _getTontines(const NoParams());
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}
