import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// ============================================================================
// HASH UTILITY CLASS - One-way hashing for sensitive operations
// ============================================================================
class HashUtil {
  /// Generate SHA-256 hash with salt
  static String generateHash(String input, {String? salt}) {
    final saltValue = salt ?? _generateSalt();
    final combined = input + saltValue;
    return sha256.convert(utf8.encode(combined)).toString();
  }

  /// Generate a random salt
  static String _generateSalt({int length = 16}) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return random.substring(0, length.clamp(0, random.length));
  }

  /// Verify hash (compare input hash with stored hash)
  static bool verifyHash(String input, String storedHash, {String? salt}) {
    final computedHash = generateHash(input, salt: salt);
    return computedHash == storedHash;
  }

  /// Generate device fingerprint hash
  static String generateDeviceFingerprint(String deviceId, String userAgent) {
    return sha256.convert(utf8.encode('$deviceId:$userAgent')).toString();
  }
}

// ============================================================================
// ENHANCED AUTH SERVICE WITH HASH KEY AUTHENTICATION
// ============================================================================
class AuthService {
  final Dio _dio;
  final String baseUrl = 'https://potbelly-postlarval-bronson.ngrok-free.dev/api/health';

  // Store hash keys for session management
  Map<String, String> _hashKeyStore = {};

  AuthService({Dio? dio}) : _dio = dio ?? Dio();

  void initialize() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        request: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );
  }

  /// Generate one-way hash key for authentication
  String _generateHashKey(String identifier, String timestamp) {
    return HashUtil.generateHash('$identifier:$timestamp');
  }

  /// Send OTP via SMS with hash key validation
  Future<OTPResponse> sendOTPBySMS(String phoneNumber) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final hashKey = _generateHashKey(phoneNumber, timestamp);

      final response = await _dio.post(
        '/auth/otp/send',
        data: {
          'phone': phoneNumber,
          'method': 'sms',
          'hashKey': hashKey,
          'timestamp': timestamp,
        },
      );

      // Store hash key for later verification
      _hashKeyStore[phoneNumber] = hashKey;

      return OTPResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Send OTP via WhatsApp with hash key validation
  Future<OTPResponse> sendOTPByWhatsApp(String phoneNumber) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final hashKey = _generateHashKey(phoneNumber, timestamp);

      final response = await _dio.post(
        '/auth/otp/send',
        data: {
          'phone': phoneNumber,
          'method': 'whatsapp',
          'hashKey': hashKey,
          'timestamp': timestamp,
        },
      );

      _hashKeyStore[phoneNumber] = hashKey;

      return OTPResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Send OTP via Email with hash key validation
  Future<OTPResponse> sendOTPByEmail(String email) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final hashKey = _generateHashKey(email, timestamp);

      final response = await _dio.post(
        '/auth/otp/send',
        data: {
          'email': email,
          'method': 'email',
          'hashKey': hashKey,
          'timestamp': timestamp,
        },
      );

      _hashKeyStore[email] = hashKey;

      return OTPResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Verify OTP and login (for SMS/WhatsApp/Email)
  Future<AuthResponse> verifyOTPAndLogin(
      String identifier,
      String otp,
      ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final hashKey = _generateHashKey(identifier, timestamp);
      final storedHashKey = _hashKeyStore[identifier] ?? '';

      final response = await _dio.post(
        '/auth/otp/verify',
        data: {
          'identifier': identifier,
          'code': otp,
          'hashKey': hashKey,
          'storedHashKey': storedHashKey,
          'timestamp': timestamp,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Clear hash key after successful authentication
      if (authResponse.success) {
        _hashKeyStore.remove(identifier);
      }

      return authResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Login with username and password using hash key
  Future<AuthResponse> loginWithUsernamePassword(
      String username,
      String password,
      ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Hash the password with salt
      final passwordHash = HashUtil.generateHash(password);
      final authHashKey = _generateHashKey('$username:$password', timestamp);

      final response = await _dio.post(
        '/auth/login',
        data: {
          'identifier': username,
          'passwordHash': passwordHash,
          'authHashKey': authHashKey,
          'timestamp': timestamp,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Send password reset link with hash key
  Future<void> sendPasswordReset(String identifier) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final hashKey = _generateHashKey(identifier, timestamp);

      await _dio.post(
        '/auth/password/reset',
        data: {
          'identifier': identifier,
          'hashKey': hashKey,
          'timestamp': timestamp,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Register new user with hash validation
  Future<AuthResponse> register({
    required String email,
    required String phone,
    required String name,
    required String password,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final passwordHash = HashUtil.generateHash(password);
      final registrationHashKey = _generateHashKey('$email:$phone', timestamp);

      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'phone': phone,
          'name': name,
          'passwordHash': passwordHash,
          'registrationHashKey': registrationHashKey,
          'timestamp': timestamp,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Validate email format
  Future<bool> validateEmail(String email) async {
    try {
      final response = await _dio.post(
        '/auth/validate/email',
        data: {'email': email},
      );

      return response.data['valid'] ?? false;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Validate phone format
  Future<bool> validatePhone(String phone) async {
    try {
      final response = await _dio.post(
        '/auth/validate/phone',
        data: {'phone': phone},
      );

      return response.data['valid'] ?? false;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Error handling
  String _handleDioError(DioException e) {
    if (e.response != null) {
      final errorMessage = e.response?.data['message'] ??
          e.response?.statusMessage ??
          'An error occurred';
      return errorMessage;
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server timeout. Please try again.';
    } else if (e.type == DioExceptionType.unknown) {
      if (e.message?.contains('SocketException') ?? false) {
        return 'No internet connection. Please check your network.';
      }
      return 'Network error: ${e.message}';
    } else {
      return 'An error occurred: ${e.message}';
    }
  }

  /// Clear all stored hash keys (logout)
  void clearHashKeys() {
    _hashKeyStore.clear();
  }
}

// ============================================================================
// RESPONSE MODELS
// ============================================================================

class OTPResponse {
  final bool success;
  final String message;
  final String? requestId;
  final int expiresIn;

  OTPResponse({
    required this.success,
    required this.message,
    this.requestId,
    this.expiresIn = 600,
  });

  factory OTPResponse.fromJson(Map<String, dynamic> json) {
    return OTPResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      requestId: json['requestId'],
      expiresIn: json['expiresIn'] ?? 600,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'requestId': requestId,
      'expiresIn': expiresIn,
    };
  }
}

class AuthResponse {
  final bool success;
  final String? token;
  final String? message;
  final Map<String, dynamic>? user;

  AuthResponse({
    required this.success,
    this.token,
    this.message,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      token: json['token'],
      message: json['message'],
      user: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'token': token,
      'message': message,
      'user': user,
    };
  }
}