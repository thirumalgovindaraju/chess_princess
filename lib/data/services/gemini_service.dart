// ==================== FILE 3: lib/data/services/gemini_service.dart ====================

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../presentation/services/ai_service_base.dart';

class GeminiService implements AIService {
  final String apiKey;
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  GeminiService({required this.apiKey});

  @override
  String get serviceName => 'Google Gemini';

  @override
  bool get requiresApiKey => true;

  @override
  Future<AIResponse> processQuestion(
      String question, {
        String? imagePath,
      }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/models/gemini-pro:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': _buildChessPrompt(question)}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];

        return AIResponse(
          content: content,
          steps: extractSteps(content),
          serviceName: serviceName,
        );
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Gemini error: $e');
      return AIResponse(
        content: '',
        hasError: true,
        error: e.toString(),
        serviceName: serviceName,
      );
    }
  }

  String _buildChessPrompt(String question) {
    return '''You are a helpful chess coach and expert. Answer the following chess question clearly and concisely:

$question

Provide practical advice that helps players improve their game. Use chess notation where appropriate and explain concepts in an accessible way.''';
  }
}
