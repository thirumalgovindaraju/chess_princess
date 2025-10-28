class OTPRequest {
  final String phone;
  final String email;
  final String method; // 'sms', 'whatsapp', 'email'

  OTPRequest({
    required this.phone,
    required this.email,
    required this.method,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
      'method': method,
    };
  }
}

class OTPResponse {
  final bool success;
  final String message;
  final String? requestId;
  final int expiresIn;

  OTPResponse({
    required this.success,
    required this.message,
    this.requestId,
    this.expiresIn = 600, // 10 minutes
  });

  factory OTPResponse.fromJson(Map<String, dynamic> json) {
    return OTPResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      requestId: json['requestId'],
      expiresIn: json['expiresIn'] ?? 600,
    );
  }
}

class LoginRequest {
  final String identifier; // email, phone, or username
  final String? code; // OTP or password
  final String? password;

  LoginRequest({
    required this.identifier,
    this.code,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      if (code != null) 'code': code,
      if (password != null) 'password': password,
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
}