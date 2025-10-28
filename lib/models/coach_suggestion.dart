// lib/models/coach_suggestion.dart

enum SuggestionType {
  tactical,
  positional,
  strategic,
  mistake,
  warning,
  praise,
  opening,
  endgame,
}

enum SuggestionPriority {
  critical,
  high,
  medium,
  low,
}

class CoachSuggestion {
  final String id;
  final SuggestionType type;
  final SuggestionPriority priority;
  final String title;
  final String message;
  final String? move;
  final String? explanation;
  final List<String>? variations;
  final DateTime timestamp;

  CoachSuggestion({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    this.move,
    this.explanation,
    this.variations,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'priority': priority.toString(),
      'title': title,
      'message': message,
      'move': move,
      'explanation': explanation,
      'variations': variations,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CoachSuggestion.fromJson(Map<String, dynamic> json) {
    return CoachSuggestion(
      id: json['id'],
      type: SuggestionType.values.firstWhere(
            (e) => e.toString() == json['type'],
      ),
      priority: SuggestionPriority.values.firstWhere(
            (e) => e.toString() == json['priority'],
      ),
      title: json['title'],
      message: json['message'],
      move: json['move'],
      explanation: json['explanation'],
      variations: json['variations'] != null
          ? List<String>.from(json['variations'])
          : null,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class CoachAnalysis {
  final List<CoachSuggestion> suggestions;
  final double positionEvaluation;
  final String gamePhase;
  final Map<String, dynamic> statistics;
  final List<String> bestMoves;

  CoachAnalysis({
    required this.suggestions,
    required this.positionEvaluation,
    required this.gamePhase,
    required this.statistics,
    required this.bestMoves,
  });

  Map<String, dynamic> toJson() {
    return {
      'suggestions': suggestions.map((s) => s.toJson()).toList(),
      'positionEvaluation': positionEvaluation,
      'gamePhase': gamePhase,
      'statistics': statistics,
      'bestMoves': bestMoves,
    };
  }

  factory CoachAnalysis.fromJson(Map<String, dynamic> json) {
    return CoachAnalysis(
      suggestions: (json['suggestions'] as List)
          .map((s) => CoachSuggestion.fromJson(s))
          .toList(),
      positionEvaluation: json['positionEvaluation'],
      gamePhase: json['gamePhase'],
      statistics: json['statistics'],
      bestMoves: List<String>.from(json['bestMoves']),
    );
  }
}