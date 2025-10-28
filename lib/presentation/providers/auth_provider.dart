// lib/presentation/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import '../../data/services/auth_service.dart';
import '../../core/enums/auth_enums.dart';

/// AuthProvider manages authentication state and user session
class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _user;
  String? _errorMessage;

  AuthProvider(this._authService) {
    _initializeAuth();
  }

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  String? get errorMessage => _errorMessage;

  /// Initialize authentication state from stored session
  Future<void> _initializeAuth() async {
    try {
      final session = await _authService.getStoredSession();
      if (session != null) {
        _token = session['token'];
        _user = session['user'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to initialize auth: $e');
    }
  }

  /// Send verification code via SMS, WhatsApp, or Email
  Future<void> sendVerificationCode(
      LoginMethod method,
      String recipient,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendVerificationCode(
        method: method,
        recipient: recipient,
      );
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Login with SMS verification
  Future<void> loginWithSMS(String phone, String verificationCode) async {
    await _performLogin(() => _authService.loginWithSMS(
      phone: phone,
      verificationCode: verificationCode,
    ));
  }

  /// Login with WhatsApp verification
  Future<void> loginWithWhatsApp(String phone, String verificationCode) async {
    await _performLogin(() => _authService.loginWithWhatsApp(
      phone: phone,
      verificationCode: verificationCode,
    ));
  }

  /// Login with Email verification
  Future<void> loginWithEmail(String email, String verificationCode) async {
    await _performLogin(() => _authService.loginWithEmail(
      email: email,
      verificationCode: verificationCode,
    ));
  }

  /// Login with Username and Password
  Future<void> loginWithUsername(String username, String password) async {
    await _performLogin(() => _authService.loginWithUsername(
      username: username,
      password: password,
    ));
  }

  /// Register new user
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _performLogin(() => _authService.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    ));
  }

  /// Send password reset link
  Future<void> sendPasswordResetLink(String recipient) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetLink(recipient: recipient);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout user
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.clearSession();
      _token = null;
      _user = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      debugPrint('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh user session
  Future<void> refreshSession() async {
    try {
      final session = await _authService.getStoredSession();
      if (session != null) {
        _token = session['token'];
        _user = session['user'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to refresh session: $e');
    }
  }

  // Private helper methods

  Future<void> _performLogin(
      Future<Map<String, dynamic>> Function() loginFunction,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await loginFunction();

      // Store session
      await _authService.storeSession(result);

      // Update state
      _token = result['token'];
      _user = result['user'];

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}