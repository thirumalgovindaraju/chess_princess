import 'dart:convert';

class UserProgressModel {
  final String userId;
  final int puzzlesSolved;
  final double accuracy;
  final DateTime lastUpdated;

  UserProgressModel({
    required this.userId,
    required this.puzzlesSolved,
    required this.accuracy,
    required this.lastUpdated,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      userId: json['userId'],
      puzzlesSolved: json['puzzlesSolved'],
      accuracy: json['accuracy'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'puzzlesSolved': puzzlesSolved,
      'accuracy': accuracy,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
