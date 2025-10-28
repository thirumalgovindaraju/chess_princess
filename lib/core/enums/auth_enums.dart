/// Authentication login methods
enum LoginMethod {
  sms,
  whatsapp,
  email,
  username,
}

/// Authentication status
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

/// Registration status
enum RegistrationStatus {
  initial,
  loading,
  success,
  failure,
}

/// OTP verification status
enum OTPStatus {
  notSent,
  sent,
  verified,
  expired,
  invalid,
}