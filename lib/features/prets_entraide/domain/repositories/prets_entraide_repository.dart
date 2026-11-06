import '../entities/loan_and_aid.dart';

abstract class PretsEntraideRepository {
  Future<List<Loan>> getLoans();
  Future<List<AidEvent>> getAidEvents();
}
