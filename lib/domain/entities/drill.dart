// lib/domain/entities/drill.dart - CORRECTED VERSION
enum DrillType {
  endgame,
  opening,
  middlegame,
  tactics,
  strategy,
}

extension DrillTypeExtension on DrillType {
  String get name {
    switch (this) {
      case DrillType.endgame:
        return 'Endgame';
      case DrillType.opening:
        return 'Opening';
      case DrillType.middlegame:
        return 'Middlegame';
      case DrillType.tactics:
        return 'Tactics';
      case DrillType.strategy:
        return 'Strategy';
    }
  }

  String get description {
    switch (this) {
      case DrillType.endgame:
        return 'Master essential endgame techniques and patterns';
      case DrillType.opening:
        return 'Learn and practice popular chess openings';
      case DrillType.middlegame:
        return 'Improve your middlegame planning and tactics';
      case DrillType.tactics:
        return 'Sharpen your tactical vision and calculation';
      case DrillType.strategy:
        return 'Develop strategic understanding and planning';
    }
  }

  static DrillType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'endgame':
        return DrillType.endgame;
      case 'opening':
        return DrillType.opening;
      case 'middlegame':
        return DrillType.middlegame;
      case 'tactics':
        return DrillType.tactics;
      case 'strategy':
        return DrillType.strategy;
      default:
        return DrillType.tactics;
    }
  }
}

class Drill {
  final String id;
  final String name;
  final String? description;
  final DrillType type;
  final String difficulty; // Changed from int to String to match UI usage
  final List<String> solutionMoves; // Renamed from exercises
  final List<String> hints;
  final String fen;
  final List<DrillExercise> exercises; // Keep for backward compatibility

  Drill({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.difficulty,
    required this.solutionMoves,
    this.hints = const [],
    required this.fen,
    this.exercises = const [],
  });

  factory Drill.fromJson(Map<String, dynamic> json) {
    return Drill(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: DrillTypeExtension.fromString(json['type'] as String? ?? 'tactics'),
      difficulty: json['difficulty'] as String? ?? 'intermediate',
      solutionMoves: (json['solutionMoves'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      hints: (json['hints'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      fen: json['fen'] as String? ?? 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => DrillExercise.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'difficulty': difficulty,
      'solutionMoves': solutionMoves,
      'hints': hints,
      'fen': fen,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

class DrillExercise {
  final String id;
  final String fen;
  final String instruction;
  final List<String> correctMoves;
  final String? hint;

  DrillExercise({
    required this.id,
    required this.fen,
    required this.instruction,
    required this.correctMoves,
    this.hint,
  });

  factory DrillExercise.fromJson(Map<String, dynamic> json) {
    return DrillExercise(
      id: json['id'] as String,
      fen: json['fen'] as String,
      instruction: json['instruction'] as String,
      correctMoves: (json['correctMoves'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      hint: json['hint'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fen': fen,
      'instruction': instruction,
      'correctMoves': correctMoves,
      'hint': hint,
    };
  }
}