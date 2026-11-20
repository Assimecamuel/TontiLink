import 'package:flutter/foundation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/caisse_summary.dart';
import '../../domain/usecases/get_caisse_summary.dart';

class CaisseController extends ChangeNotifier {
  CaisseController({required GetCaisseSummary getCaisseSummary}) : _getCaisseSummary = getCaisseSummary;

  final GetCaisseSummary _getCaisseSummary;

  CaisseSummary? _caisseSummary;
  bool _isLoading = false;
  String? _errorMessage;

  /// Disponible après [load] (appelé au démarrage par l'injection de dépendances).
  CaisseSummary get caisseSummary => _caisseSummary!;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _caisseSummary = await _getCaisseSummary(const NoParams());
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
