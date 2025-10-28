import '../models/chess_puzzle.dart';
import '../models/chess_board.dart';
import '../models/position.dart';

class PuzzleImageData {
  final String imagePath;
  final List<PuzzleDefinition> puzzles;
  final String? title;
  final String? source;

  PuzzleImageData({
    required this.imagePath,
    required this.puzzles,
    this.title,
    this.source,
  });

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'puzzles': puzzles.map((p) => p.toJson()).toList(),
      'title': title,
      'source': source,
    };
  }

  factory PuzzleImageData.fromJson(Map<String, dynamic> json) {
    return PuzzleImageData(
      imagePath: json['imagePath'] ?? '',
      puzzles: (json['puzzles'] as List<dynamic>?)
          ?.map((p) => PuzzleDefinition.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
      title: json['title'],
      source: json['source'],
    );
  }
}

class PuzzleDefinition {
  final String id;
  final String fen; // Chess position in FEN notation
  final List<String> solution; // Moves in algebraic notation
  final String? description;
  final PuzzleDifficulty difficulty;
  final String theme;
  final int? movesToMate;
  final PieceColor playerColor;
  final Map<String, dynamic>? metadata;

  PuzzleDefinition({
    required this.id,
    required this.fen,
    required this.solution,
    this.description,
    this.difficulty = PuzzleDifficulty.medium,
    this.theme = 'Tactics',
    this.movesToMate,
    this.playerColor = PieceColor.white,
    this.metadata,
  });

  // Convert to ChessPuzzle
  ChessPuzzle toChessPuzzle() {
    return ChessPuzzle(
      id: id,
      name: theme,
      description: description ?? 'Solve this chess puzzle',
      difficulty: difficulty,
      theme: theme,
      fenPosition: fen,
      solution: solution,
      movesToMate: movesToMate ?? 0,
      playerColor: playerColor,
      hints: _generateHints(),
    );
  }

  // Generate hints based on puzzle theme and solution
  List<String> _generateHints() {
    List<String> hints = [];

    // Add theme-based hint
    switch (theme.toLowerCase()) {
      case 'checkmate':
        hints.add('Look for a move that delivers checkmate!');
        break;
      case 'fork':
        hints.add('Find a move that attacks two pieces at once.');
        break;
      case 'pin':
        hints.add('Look for a way to pin a piece to the king or a valuable piece.');
        break;
      case 'discovered attack':
        hints.add('Move one piece to reveal an attack from another.');
        break;
      case 'deflection':
        hints.add('Force the defending piece away from its important duty.');
        break;
      case 'promotion':
        hints.add('Your pawn can become a more powerful piece.');
        break;
      case 'sacrifice':
        hints.add('Sometimes you must give up material for a greater advantage.');
        break;
      default:
        hints.add('Look for the strongest move in this position.');
    }

    // Add solution-specific hints
    if (solution.isNotEmpty) {
      String firstMove = solution[0].toLowerCase();

      if (firstMove.contains('#')) {
        hints.add('This move delivers checkmate!');
      } else if (firstMove.contains('+')) {
        hints.add('This move gives check.');
      }

      if (firstMove.startsWith('q')) {
        hints.add('The queen has the key move.');
      } else if (firstMove.startsWith('r')) {
        hints.add('The rook is your strongest piece here.');
      } else if (firstMove.startsWith('n')) {
        hints.add('Think about the unique way knights move.');
      } else if (firstMove.startsWith('b')) {
        hints.add('The bishop attacks along diagonals.');
      } else if (firstMove.contains('=')) {
        hints.add('Consider promoting your pawn.');
      }
    }

    return hints;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fen': fen,
      'solution': solution,
      'description': description,
      'difficulty': difficulty.name,
      'theme': theme,
      'movesToMate': movesToMate,
      'playerColor': playerColor.name,
      'metadata': metadata,
    };
  }

  factory PuzzleDefinition.fromJson(Map<String, dynamic> json) {
    return PuzzleDefinition(
      id: json['id'] ?? '',
      fen: json['fen'] ?? '',
      solution: List<String>.from(json['solution'] ?? []),
      description: json['description'],
      difficulty: _parseDifficulty(json['difficulty']),
      theme: json['theme'] ?? 'Tactics',
      movesToMate: json['movesToMate'],
      playerColor: _parseColor(json['playerColor']),
      metadata: json['metadata'],
    );
  }

  static PuzzleDifficulty _parseDifficulty(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return PuzzleDifficulty.easy;
      case 'medium':
        return PuzzleDifficulty.medium;
      case 'hard':
        return PuzzleDifficulty.hard;
      case 'expert':
        return PuzzleDifficulty.expert;
      default:
        return PuzzleDifficulty.medium;
    }
  }

  static PieceColor _parseColor(String? color) {
    return color?.toLowerCase() == 'black' ? PieceColor.black : PieceColor.white;
  }

  PuzzleDefinition copyWith({
    String? id,
    String? fen,
    List<String>? solution,
    String? description,
    PuzzleDifficulty? difficulty,
    String? theme,
    int? movesToMate,
    PieceColor? playerColor,
    Map<String, dynamic>? metadata,
  }) {
    return PuzzleDefinition(
      id: id ?? this.id,
      fen: fen ?? this.fen,
      solution: solution ?? this.solution,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      theme: theme ?? this.theme,
      movesToMate: movesToMate ?? this.movesToMate,
      playerColor: playerColor ?? this.playerColor,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PuzzleDefinition && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PuzzleDefinition(id: $id, theme: $theme, difficulty: $difficulty)';
  }

  // Validation method to check if puzzle data is valid
  bool isValid() {
    return id.isNotEmpty &&
        fen.isNotEmpty &&
        solution.isNotEmpty &&
        _isValidFen(fen);
  }

  // Basic FEN validation
  bool _isValidFen(String fen) {
    List<String> parts = fen.split(' ');
    if (parts.length != 6) return false;

    // Check if position part has 8 ranks
    List<String> ranks = parts[0].split('/');
    return ranks.length == 8;
  }

  // Get the expected next move for hint purposes
  String? getExpectedMove(int moveIndex) {
    if (moveIndex >= 0 && moveIndex < solution.length) {
      return solution[moveIndex];
    }
    return null;
  }

  // Check if puzzle is a checkmate puzzle
  bool get isMatePuzzle => movesToMate != null && movesToMate! > 0;

  // Get difficulty as integer for sorting
  int get difficultyIndex {
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        return 1;
      case PuzzleDifficulty.medium:
        return 2;
      case PuzzleDifficulty.hard:
        return 3;
      case PuzzleDifficulty.expert:
        return 4;
    }
  }
}