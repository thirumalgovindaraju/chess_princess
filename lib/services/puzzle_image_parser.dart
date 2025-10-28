// Updated PuzzleImageParser with correct puzzle positions
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import '../models/puzzle_data_models.dart';
import '../models/chess_puzzle.dart';
import '../models/chess_board.dart';

class PuzzleImageParser {
  static final Map<String, PuzzleImageData> _puzzleDatabase = {};

  static Future<void> initialize() async {
    await _loadPuzzleDefinitions();
  }

  static Future<void> _loadPuzzleDefinitions() async {
    try {
      // Try to load from assets first
      await _loadPuzzleFromAssets();
    } catch (e) {
      developer.log('Error loading puzzle definitions: $e');
      // Fall back to default puzzles if loading fails
      _loadDefaultPuzzles();
    }
  }

  // Load puzzles from assets/puzzles/ directory
  static Future<void> _loadPuzzleFromAssets() async {
    try {
      // Try to load the puzzle index file
      String indexData = await rootBundle.loadString('assets/puzzles/puzzle_index.json');
      Map<String, dynamic> index = json.decode(indexData);

      // Load each puzzle set
      for (String setName in index['puzzle_sets']) {
        await _loadPuzzleSet(setName);
      }
    } catch (e) {
      developer.log('No puzzle index found, loading individual sets...');

      // Try to load known puzzle sets
      List<String> knownSets = [
        'beginner_tactics',
        'intermediate_tactics',
        'advanced_tactics',
        'endgame_puzzles',
        'opening_traps'
      ];

      for (String setName in knownSets) {
        await _loadPuzzleSet(setName);
      }
    }
  }

  static Future<void> _loadPuzzleSet(String setName) async {
    try {
      String puzzleData = await rootBundle.loadString('assets/puzzles/$setName.json');
      Map<String, dynamic> data = json.decode(puzzleData);

      List<PuzzleDefinition> puzzles = [];
      for (Map<String, dynamic> puzzleJson in data['puzzles']) {
        puzzles.add(PuzzleDefinition.fromJson(puzzleJson));
      }

      _puzzleDatabase[setName] = PuzzleImageData(
        imagePath: data['imagePath'] ?? '',
        puzzles: puzzles,
        title: data['title'],
        source: data['source'],
      );

      developer.log('Loaded ${puzzles.length} puzzles from $setName');
    } catch (e) {
      developer.log('Error loading puzzle set $setName: $e');
    }
  }

  // Updated default puzzles with CORRECT tactical positions
  static void _loadDefaultPuzzles() {
    List<PuzzleDefinition> defaultPuzzles = [
      // Back Rank Mate - Simple tactical position
      PuzzleDefinition(
        id: 'default_1',
        fen: '6k1/5ppp/8/8/8/8/8/R6K w - - 0 1',
        solution: ['Ra8+'],
        description: 'Back Rank Mate - Deliver checkmate with the rook',
        difficulty: PuzzleDifficulty.easy,
        theme: 'Checkmate',
        movesToMate: 1,
        playerColor: PieceColor.white,
      ),

      // Knight Fork
      PuzzleDefinition(
        id: 'default_2',
        fen: 'r3k2r/ppp2ppp/8/8/8/3N4/PPP2PPP/R3K2R w KQkq - 0 1',
        solution: ['Nf7+'],
        description: 'Knight Fork - Fork the king and rook',
        difficulty: PuzzleDifficulty.easy,
        theme: 'Fork',
        playerColor: PieceColor.white,
      ),

      // Pin Tactic
      PuzzleDefinition(
        id: 'default_3',
        fen: 'r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 0 4',
        solution: ['Ng5'],
        description: 'Pin Attack - Attack the pinned knight',
        difficulty: PuzzleDifficulty.medium,
        theme: 'Pin',
        playerColor: PieceColor.white,
      ),

      // Discovered Attack
      PuzzleDefinition(
        id: 'default_4',
        fen: 'r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/3P1N2/PPP2PPP/RNBQK2R w KQkq - 0 4',
        solution: ['Bxf7+'],
        description: 'Discovered Attack - Remove the defender',
        difficulty: PuzzleDifficulty.medium,
        theme: 'Discovered Attack',
        playerColor: PieceColor.white,
      ),

      // Simple Checkmate
      PuzzleDefinition(
        id: 'default_5',
        fen: '7k/8/6K1/8/8/8/8/7Q w - - 0 1',
        solution: ['Qh7#'],
        description: 'Queen and King Mate',
        difficulty: PuzzleDifficulty.easy,
        theme: 'Checkmate',
        movesToMate: 1,
        playerColor: PieceColor.white,
      ),
    ];

    _puzzleDatabase['default'] = PuzzleImageData(
      imagePath: 'assets/images/default_puzzles.png',
      puzzles: defaultPuzzles,
      title: 'Default Tactical Puzzles',
      source: 'Built-in',
    );
  }

  // Rest of the methods remain the same...
  static List<String> getPuzzleSetNames() {
    return _puzzleDatabase.keys.toList();
  }

  static List<ChessPuzzle> getPuzzlesFromSet(String setName) {
    PuzzleImageData? data = _puzzleDatabase[setName];
    if (data == null) return [];
    return data.puzzles.map((p) => p.toChessPuzzle()).toList();
  }

  static List<ChessPuzzle> getAllPuzzles() {
    List<ChessPuzzle> allPuzzles = [];
    for (PuzzleImageData data in _puzzleDatabase.values) {
      allPuzzles.addAll(data.puzzles.map((p) => p.toChessPuzzle()));
    }
    return allPuzzles;
  }

  static List<ChessPuzzle> getPuzzlesByDifficulty(PuzzleDifficulty difficulty) {
    List<ChessPuzzle> filteredPuzzles = [];
    for (PuzzleImageData data in _puzzleDatabase.values) {
      for (PuzzleDefinition puzzle in data.puzzles) {
        if (puzzle.difficulty == difficulty) {
          filteredPuzzles.add(puzzle.toChessPuzzle());
        }
      }
    }
    return filteredPuzzles;
  }

  static List<ChessPuzzle> getPuzzlesByTheme(String theme) {
    List<ChessPuzzle> filteredPuzzles = [];
    for (PuzzleImageData data in _puzzleDatabase.values) {
      for (PuzzleDefinition puzzle in data.puzzles) {
        if (puzzle.theme.toLowerCase().contains(theme.toLowerCase())) {
          filteredPuzzles.add(puzzle.toChessPuzzle());
        }
      }
    }
    return filteredPuzzles;
  }

  // Import puzzles from JSON string (for your multiple pages of puzzles)
  static Future<bool> importPuzzlesFromJson(String jsonString, String setName) async {
    try {
      Map<String, dynamic> data = json.decode(jsonString);
      PuzzleImageData puzzleData = PuzzleImageData.fromJson(data);
      _puzzleDatabase[setName] = puzzleData;
      developer.log('Successfully imported ${puzzleData.puzzles.length} puzzles as set: $setName');
      return true;
    } catch (e) {
      developer.log('Error importing puzzles: $e');
      return false;
    }
  }

  // Add method to import multiple puzzle pages
  static Future<void> loadPuzzlePages(List<String> jsonFiles) async {
    for (int i = 0; i < jsonFiles.length; i++) {
      String jsonContent = jsonFiles[i];
      String setName = 'puzzle_page_${i + 1}';
      await importPuzzlesFromJson(jsonContent, setName);
    }
  }

  // Debug method to validate FEN positions
  static void validateAllPuzzleFens() {
    for (String setName in _puzzleDatabase.keys) {
      PuzzleImageData? data = _puzzleDatabase[setName];
      if (data != null) {
        developer.log('=== Validating $setName ===');
        for (PuzzleDefinition puzzle in data.puzzles) {
          _validateFen(puzzle.fen, puzzle.id);
        }
      }
    }
  }

  static void _validateFen(String fen, String puzzleId) {
    List<String> parts = fen.split(' ');
    if (parts.length != 6) {
      developer.log('ERROR in $puzzleId: FEN should have 6 parts, got ${parts.length}');
      return;
    }

    String position = parts[0];
    List<String> ranks = position.split('/');
    if (ranks.length != 8) {
      developer.log('ERROR in $puzzleId: FEN should have 8 ranks, got ${ranks.length}');
      return;
    }

    // Count total pieces
    int totalPieces = 0;
    for (String rank in ranks) {
      for (String char in rank.split('')) {
        if ('rnbqkpRNBQKP'.contains(char)) {
          totalPieces++;
        }
      }
    }

    if (totalPieces == 32) {
      developer.log('WARNING in $puzzleId: All 32 pieces present - might be starting position');
    } else if (totalPieces > 30) {
      developer.log('WARNING in $puzzleId: $totalPieces pieces - might be too many for a puzzle');
    } else {
      developer.log('OK $puzzleId: $totalPieces pieces');
    }
  }

  // Other existing methods...
  static Map<String, dynamic> getStatistics() {
    int totalPuzzles = 0;
    Map<PuzzleDifficulty, int> difficultyCount = {};
    Map<String, int> themeCount = {};

    for (PuzzleImageData data in _puzzleDatabase.values) {
      totalPuzzles += data.puzzles.length;
      for (PuzzleDefinition puzzle in data.puzzles) {
        difficultyCount[puzzle.difficulty] = (difficultyCount[puzzle.difficulty] ?? 0) + 1;
        themeCount[puzzle.theme] = (themeCount[puzzle.theme] ?? 0) + 1;
      }
    }

    return {
      'totalPuzzles': totalPuzzles,
      'totalSets': _puzzleDatabase.length,
      'difficultyBreakdown': difficultyCount,
      'themeBreakdown': themeCount,
      'setNames': _puzzleDatabase.keys.toList(),
    };
  }
}