// ==================== FILE 2: lib/presentation/services/ai_service_manager.dart ====================

import 'ai_service_base.dart';
import '../../data/services/gemini_service.dart';

class AIServiceManager {
  static final List<AIService> _services = [];
  static int _currentServiceIndex = 0;
  static bool _isInitialized = false;

  static void initialize({
    String? geminiApiKey,
  }) {
    _services.clear();

    if (geminiApiKey != null &&
        geminiApiKey.isNotEmpty &&
        geminiApiKey != 'YOUR_GEMINI_API_KEY') {
      _services.add(GeminiService(apiKey: geminiApiKey));
      print('✅ Gemini Service initialized');
    } else {
      print('⚠️ Gemini API key not provided or invalid');
    }

    _isInitialized = true;
    print('🚀 AI Service Manager initialized with ${_services.length} services');
  }

  static Future<AIResponse> processQuestion(
      String question, {
        String? imagePath,
      }) async {
    if (!_isInitialized) {
      initialize();
    }

    if (_services.isEmpty) {
      print('⚠️ No AI services available, using fallback');
      return getFallbackResponseObj(question);
    }

    try {
      AIResponse response = await _services[_currentServiceIndex]
          .processQuestion(question, imagePath: imagePath);

      if (response.hasError) {
        print('❌ ${_services[_currentServiceIndex].serviceName} failed, using fallback');
        response = getFallbackResponseObj(question);
      }

      return response;
    } catch (e) {
      print('❌ Error processing question: $e');
      return getFallbackResponseObj(question);
    }
  }

  static List<String> getAvailableServices() {
    List<String> services = _services
        .map((service) => service.serviceName)
        .toList();

    if (services.isEmpty) {
      services.add('Fallback System');
    }

    return services;
  }

  static void switchToService(int index) {
    if (index >= 0 && index < _services.length) {
      _currentServiceIndex = index;
      print('🔄 Switched to ${_services[index].serviceName}');
    }
  }

  static String getCurrentServiceName() {
    if (_services.isEmpty) return 'Fallback System';
    return _services[_currentServiceIndex].serviceName;
  }

  static int getCurrentServiceIndex() {
    return _currentServiceIndex;
  }

  static int getServiceCount() {
    return _services.length;
  }

  static bool isInitialized() {
    return _isInitialized;
  }

  static void reset() {
    _services.clear();
    _currentServiceIndex = 0;
    _isInitialized = false;
    print('🔄 AI Service Manager reset');
  }
}
