import 'package:flutter/foundation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/record_transaction.dart';

class CotisationsController extends ChangeNotifier {
  CotisationsController({required GetTransactions getTransactions, required RecordTransaction recordTransaction}) : _getTransactions = getTransactions, _recordTransaction = recordTransaction;

  final GetTransactions _getTransactions;
  final RecordTransaction _recordTransaction;

  List<Transaction> _transactions = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _transactions = await _getTransactions(const NoParams());
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> recordTransaction(Transaction item) async {
    try {
      await _recordTransaction(item);
      _transactions = await _getTransactions(const NoParams());
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}
