import '../entities/caisse_summary.dart';

abstract class CaisseRepository {
  Future<CaisseSummary> getCaisseSummary();
}
