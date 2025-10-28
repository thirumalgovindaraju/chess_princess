import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/enums/auth_enums.dart';

/// AuthService handles all authentication API calls
class AuthService {
  final Dio dio;
  late SharedPreferences _prefs;
  static const String _baseUrl = 'http://localhost:5000/api';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _sessionKey = 'session_data';

  AuthService({required this.dio});

  /// Initialize the service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _setupDioInterceptor();
    } catch (e) {
      print('Failed to initialize AuthService: $e');
    }
  }

  /// Setup Dio interceptor to add token to requests
  void _setupDioInterceptor() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefs.getString(_tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expired - clear and redirect to login
            clearSession();
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Send verification code
  Future<void> sendVerificationCode({
    required LoginMethod method,
    required String recipient,
  }) async {
    try {
      final endpoint = _getVerificationEndpoint(method);
      final data = _getVerificationData(method, recipient);

      final response = await dio.post(
        '$_baseUrl/auth/$endpoint',
        data: data,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          response.data['message'] ?? 'Failed to send verification code',
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Network error';
      throw Exception('Send code failed: $errorMessage');
    } catch (e) {
      throw Exception('Error sending verification code: $e');
    }
  }

  /// Login with SMS
  Future<Map<String, dynamic>> loginWithSMS({
    required String phone,
    required String verificationCode,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/auth/login/sms',
        data: {
          'phone': phone,
          'verification_code': verificationCode,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _handleAuthResponse(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'SMS login failed');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Network error';
      throw Exception('SMS login failed: $errorMessage');
    } catch (e) {
      throw Exception('Error during SMS login: $e');
    }
  }

  /// Login with WhatsApp
  Future<Map<String, dynamic>> loginWithWhatsApp({
    required String phone,
    required String verificationCode,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/auth/login/whatsapp',
        data: {
          'phone': phone,
          'verification_code': verificationCode,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _handleAuthResponse(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'WhatsApp login failed');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Network error';
      throw Exception('WhatsApp login failed: $errorMessage');
    } catch (e) {
      throw Exception('Error during WhatsApp login: $e');
    }
  }

  /// Login with Email
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String verificationCode,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/auth/login/email',
        data: {
          'email': email,
          'verification_code': verificationCode,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _handleAuthResponse(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Email login failed');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Network error';
      throw Exception('Email login failed: $errorMessage');
    } catch (e) {
      throw Exception('Error during email login: $e');
    }
  }

  /// Login with Username and Password
  Future<Map<String, dynamic>> loginWithUsername({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/auth/login/username',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _handleAuthResponse(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Network error';
      throw Exception('Username login failed: $errorMessage');
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  /// Register user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/auth/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return _handleAuthResponse(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Network error';
      throw Exception('Registration failed: $errorMessage');
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  /// Send password reset link
  Future<void> sendPasswordResetLink({required String recipient}) async {
    try {
      final response = await dio.post(
        '$_baseUrl/auth/password-reset',
        data: {
          'recipient': recipient,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          response.data['message'] ?? 'Failed to send password reset link',
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Network error';
      throw Exception('Password reset failed: $errorMessage');
    } catch (e) {
      throw Exception('Error sending password reset link: $e');
    }
  }

  /// Store session after successful login
  Future<void> storeSession(Map<String, dynamic> data) async {
    try {
      final token = data['token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;

      if (token != null && token.isNotEmpty) {
        await _prefs.setString(_tokenKey, token);
      }

      if (user != null) {
        await _prefs.setString(_userKey, jsonEncode(user));
      }

      await _prefs.setString(_sessionKey, DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('Failed to store session: $e');
    }
  }

  /// Get stored session
  Future<Map<String, dynamic>?> getStoredSession() async {
    try {
      final token = _prefs.getString(_tokenKey);
      final userJson = _prefs.getString(_userKey);

      if (token != null && token.isNotEmpty && userJson != null) {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        return {
          'token': token,
          'user': user,
        };
      }
      return null;
    } catch (e) {
      print('Error retrieving session: $e');
      return null;
    }
  }

  /// Clear session on logout
  Future<void> clearSession() async {
    try {
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_userKey);
      await _prefs.remove(_sessionKey);
    } catch (e) {
      throw Exception('Failed to clear session: $e');
    }
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    final token = _prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Get stored token
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  /// Get stored user
  Map<String, dynamic>? getUser() {
    try {
      final userJson = _prefs.getString(_userKey);
      if (userJson != null) {
        return jsonDecode(userJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Helper methods

  String _getVerificationEndpoint(LoginMethod method) {
    switch (method) {
      case LoginMethod.sms:
        return 'send-sms-code';
      case LoginMethod.whatsapp:
        return 'send-whatsapp-code';
      case LoginMethod.email:
        return 'send-email-code';
      case LoginMethod.username:
        return 'send-code';
    }
  }

  Map<String, dynamic> _getVerificationData(
      LoginMethod method, String recipient) {
    switch (method) {
      case LoginMethod.sms:
      case LoginMethod.whatsapp:
        return {'phone': recipient};
      case LoginMethod.email:
        return {'email': recipient};
      case LoginMethod.username:
        return {'recipient': recipient};
    }
  }

  Map<String, dynamic> _handleAuthResponse(Map<String, dynamic> data) {
    final token = data['token'] ?? data['access_token'];
    final user = data['user'] ?? {};

    if (token == null) {
      throw Exception('No authentication token received from server');
    }

    return {
      'token': token.toString(),
      'user': user is Map<String, dynamic> ? user : {},
    };
  }
}