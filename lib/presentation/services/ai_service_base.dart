// ==================== FILE 1: lib/presentation/services/ai_service_base.dart ====================

abstract class AIService {
  Future<AIResponse> processQuestion(String question, {String? imagePath});
  String get serviceName;
  bool get requiresApiKey;
}

// Response model
class AIResponse {
  final String content;
  final List<String>? steps;
  final bool hasError;
  final String? error;
  final String serviceName;

  AIResponse({
    required this.content,
    this.steps,
    this.hasError = false,
    this.error,
    required this.serviceName,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'steps': steps,
      'hasError': hasError,
      'error': error,
      'serviceName': serviceName,
    };
  }

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      content: json['content'] ?? '',
      steps: json['steps'] != null ? List<String>.from(json['steps']) : null,
      hasError: json['hasError'] ?? false,
      error: json['error'],
      serviceName: json['serviceName'] ?? 'Unknown',
    );
  }
}

// Utility functions
List<String>? extractSteps(String content) {
  final stepPattern = RegExp(
    r'(?:Step \d+:|^\d+\.|•)(.+)',
    multiLine: true,
    caseSensitive: false,
  );
  final matches = stepPattern.allMatches(content);

  if (matches.isNotEmpty) {
    return matches
        .map((match) => match.group(0)?.trim() ?? '')
        .where((step) => step.isNotEmpty)
        .toList();
  }

  final lines = content
      .split('\n')
      .where((line) => line.trim().isNotEmpty)
      .toList();

  if (lines.length > 1) {
    return lines;
  }

  return null;
}

String getFallbackResponse(String question) {
  final lowerQuestion = question.toLowerCase();

  if (lowerQuestion.contains('chess') ||
      lowerQuestion.contains('move') ||
      lowerQuestion.contains('opening') ||
      lowerQuestion.contains('tactic')) {
    return _getChessFallbackResponse(lowerQuestion);
  }

  if (lowerQuestion.contains('algebra') || lowerQuestion.contains('equation')) {
    return '''To solve algebraic equations:
1. Isolate the variable on one side
2. Perform the same operation on both sides
3. Simplify step by step
4. Check your answer

For example: 2x + 5 = 11
Step 1: Subtract 5 from both sides: 2x = 6
Step 2: Divide by 2: x = 3''';
  }

  return '''I'd be happy to help you with that!

To get the best help:
1. Share the complete problem or question
2. Tell me what you've tried
3. Let me know what part you're stuck on

I can help with:
♟️ Chess strategy and tactics
📐 Math problems (algebra, geometry, calculus)
📊 Statistics and data analysis
🎓 Learning concepts and explanations''';
}

String _getChessFallbackResponse(String question) {
  if (question.contains('opening')) {
    return '''Chess Opening Principles:

1. Control the center (e4, d4, e5, d5)
2. Develop knights before bishops
3. Castle early for king safety
4. Don't move the same piece twice
5. Connect your rooks
6. Don't bring queen out too early

Popular openings for beginners:
• Italian Game (e4 e5 Nf3 Nc6 Bc4)
• Queen's Gambit (d4 d5 c4)
• French Defense (e4 e6)''';
  }

  if (question.contains('tactic')) {
    return '''Common Chess Tactics:

🎯 Fork: Attack two pieces simultaneously
📌 Pin: Piece can't move without exposing valuable piece
🗡️ Skewer: Force valuable piece to move, expose less valuable one
⚡ Discovered Attack: Moving piece reveals attack from another
❌ Double Check: Two pieces give check simultaneously
🏰 Back Rank Mate: Checkmate on opponent's back row

Practice these patterns to improve your tactical vision!''';
  }

  if (question.contains('move') || question.contains('best')) {
    return '''To find the best move:

1. Check for forcing moves (checks, captures, threats)
2. Look for tactical opportunities
3. Evaluate position after candidate moves
4. Consider your plan and strategy
5. Calculate variations 2-3 moves ahead

Key questions:
• Is my king safe?
• Can I win material?
• Is there a tactical shot?
• Does this improve my position?''';
  }

  if (question.contains('endgame')) {
    return '''Endgame Fundamentals:

1. Activate your king - it's a fighting piece!
2. Push passed pawns toward promotion
3. Use opposition to control key squares
4. Rooks belong behind passed pawns
5. Create passed pawns when possible

Basic checkmates to know:
• King + Queen vs King
• King + Rook vs King
• King + Two Bishops vs King''';
  }

  return '''Chess Strategy Tips:

📍 Position: Place pieces on strong squares
🎯 Tactics: Look for forcing moves
👑 King Safety: Castle early and protect king
♟️ Pawn Structure: Avoid weaknesses
🔄 Piece Activity: Keep pieces active and coordinated

What specific aspect would you like help with?''';
}

AIResponse getFallbackResponseObj(String question) {
  return AIResponse(
    content: getFallbackResponse(question),
    steps: extractSteps(getFallbackResponse(question)),
    serviceName: 'Fallback System',
  );
}