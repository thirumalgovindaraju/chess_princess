// lib/domain/repositories/puzzle_repository.dart

import '../../models/chess_puzzle.dart'; // ✅ Correct relative path

abstract class PuzzleRepository {
  Future<List<ChessPuzzle>> getPuzzles({
    String? categoryId,  // Changed from PuzzleType to categoryId
    int? minDifficulty,
    int? maxDifficulty,
  });

  Future<ChessPuzzle> getPuzzleById(String id);

  Future<bool> validatePuzzleSolution(String puzzleId, List<String> moves);

  Future<void> savePuzzleAttempt(String puzzleId, bool success, int timeSeconds);

  Future<List<ChessPuzzle>> getCachedPuzzles();
}