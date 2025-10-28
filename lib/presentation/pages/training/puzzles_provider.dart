// lib/presentation/pages/training/puzzles_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess_princess/domain/entities/puzzle.dart';

class PuzzlesState {
  final List<Puzzle> puzzles;
  final List<Puzzle> filteredPuzzles;
  final bool isLoading;
  final String? error;

  PuzzlesState({
    this.puzzles = const [],
    this.filteredPuzzles = const [],
    this.isLoading = false,
    this.error,
  });

  PuzzlesState copyWith({
    List<Puzzle>? puzzles,
    List<Puzzle>? filteredPuzzles,
    bool? isLoading,
    String? error,
  }) {
    return PuzzlesState(
      puzzles: puzzles ?? this.puzzles,
      filteredPuzzles: filteredPuzzles ?? this.filteredPuzzles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PuzzlesNotifier extends StateNotifier<PuzzlesState> {
  PuzzlesNotifier() : super(PuzzlesState());

  void loadPuzzles(List<Puzzle> puzzles) {
    state = state.copyWith(
      puzzles: puzzles,
      filteredPuzzles: puzzles,
      isLoading: false,
    );
  }

  void filterByDifficulty(int minDifficulty, int maxDifficulty) {
    final filtered = state.puzzles.where((puzzle) {
      return puzzle.difficulty >= minDifficulty &&
          puzzle.difficulty <= maxDifficulty;
    }).toList();

    state = state.copyWith(filteredPuzzles: filtered);
  }

  void filterByTheme(String theme) {
    final filtered = state.puzzles.where((puzzle) {
      return puzzle.theme.toLowerCase() == theme.toLowerCase();
    }).toList();

    state = state.copyWith(filteredPuzzles: filtered);
  }

  void clearFilters() {
    state = state.copyWith(filteredPuzzles: state.puzzles);
  }
}

final puzzlesProvider = StateNotifierProvider<PuzzlesNotifier, PuzzlesState>((ref) {
  return PuzzlesNotifier();
});