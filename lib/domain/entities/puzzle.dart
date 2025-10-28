// lib/domain/entities/puzzle.dart
class Puzzle {
final String id;
final String fen;
final int difficulty; // Changed from String to int
final String theme;
final String? hint;
final double rating; // Added
final List<String> solutionSan; // Added - solution moves in Standard Algebraic Notation

Puzzle({
required this.id,
required this.fen,
required this.difficulty,
required this.theme,
this.hint,
required this.rating,
required this.solutionSan,
});

// Factory constructor for creating from JSON
factory Puzzle.fromJson(Map<String, dynamic> json) {
return Puzzle(
id: json['id'] as String,
fen: json['fen'] as String,
difficulty: json['difficulty'] as int,
theme: json['theme'] as String,
hint: json['hint'] as String?,
rating: (json['rating'] as num?)?.toDouble() ?? 1500.0,
solutionSan: (json['solutionSan'] as List<dynamic>?)
    ?.map((e) => e.toString())
    .toList() ?? [],
);
}

Map<String, dynamic> toJson() {
return {
'id': id,
'fen': fen,
'difficulty': difficulty,
'theme': theme,
'hint': hint,
'rating': rating,
'solutionSan': solutionSan,
};
}
}