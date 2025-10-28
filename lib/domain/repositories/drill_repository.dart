// lib/domain/repositories/drill_repository.dart
import '../entities/drill.dart';

abstract class DrillRepository {
  Future<List<Drill>> getDrills({String? type});
  Future<Drill> getDrillById(String id);
  Future<void> createCustomDrill(Drill drill);
  Future<void> saveDrillAttempt(String drillId, bool success);
  Future<List<Drill>> getCachedDrills();
}