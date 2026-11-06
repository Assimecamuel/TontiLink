import 'package:flutter/foundation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/distribution.dart';
import '../../domain/usecases/get_distributions.dart';

class DistributionsController extends ChangeNotifier {
  DistributionsController({required GetDistributions getDistributions}) : _getDistributions = getDistributions;

  final GetDistributions _getDistributions;

  List<Distribution> _distributions = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Distribution> get distributions => _distributions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _distributions = await _getDistributions(const NoParams());
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
