import '../entities/tontine.dart';

abstract class TontineRepository {
  Future<List<Tontine>> getTontines();
  Future<void> addTontine(Tontine item);
}
