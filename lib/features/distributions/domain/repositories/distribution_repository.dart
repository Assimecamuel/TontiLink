import '../entities/distribution.dart';

abstract class DistributionRepository {
  Future<List<Distribution>> getDistributions();
}
