// lib/presentation/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/enums/auth_enums.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _loginMethod = 'email';

  // Controllers
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isOTPSent = false;
  int _otpCountdown = 0;

  String _selectedCountryCode = '+91';
  final List<Map<String, String>> _countryCodes = [
    {'code': '+91', 'country': 'India', 'flag': '🇮🇳'},
    {'code': '+1', 'country': 'USA', 'flag': '🇺🇸'},
    {'code': '+44', 'country': 'UK', 'flag': '🇬🇧'},
    {'code': '+971', 'country': 'UAE', 'flag': '🇦🇪'},
    {'code': '+65', 'country': 'Singapore', 'flag': '🇸🇬'},
  ];

  final Map<String, String> _testCredentials = {
    'username': 'admin',
    'password': 'admin123',
  };

  @override
  void initState() {
    super.initState();
    _usernameController.text = _testCredentials['username']!;
    _passwordController.text = _testCredentials['password']!;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _startOTPTimer() {
    if (!mounted) return;
    setState(() {
      _isOTPSent = true;
      _otpCountdown = 60;
    });
    _countdown();
  }

  void _countdown() {
    if (!mounted) return;
    if (_otpCountdown > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _otpCountdown--;
          });
          _countdown();
        }
      });
    } else {
      if (mounted) {
        setState(() {
          _isOTPSent = false;
        });
      }
    }
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    try {
      switch (_loginMethod) {
        case 'sms':
          final fullPhone = _selectedCountryCode + _phoneController.text;
          await authProvider.loginWithSMS(
            fullPhone,
            _verificationCodeController.text,
          );
          break;
        case 'whatsapp':
          final fullPhone = _selectedCountryCode + _phoneController.text;
          await authProvider.loginWithWhatsApp(
            fullPhone,
            _verificationCodeController.text,
          );
          break;
        case 'email':
          await authProvider.loginWithEmail(
            _emailController.text,
            _verificationCodeController.text,
          );
          break;
        case 'username':
          await authProvider.loginWithUsername(
            _usernameController.text,
            _passwordController.text,
          );
          break;
      }

      if (authProvider.isAuthenticated && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _sendVerificationCode() async {
    final authProvider = context.read<AuthProvider>();

    LoginMethod method;
    String recipient;

    switch (_loginMethod) {
      case 'sms':
        if (!_formKey.currentState!.validate()) return;
        method = LoginMethod.sms;
        recipient = _selectedCountryCode + _phoneController.text;
        break;
      case 'whatsapp':
        if (!_formKey.currentState!.validate()) return;
        method = LoginMethod.whatsapp;
        recipient = _selectedCountryCode + _phoneController.text;
        break;
      case 'email':
        if (!_formKey.currentState!.validate()) return;
        method = LoginMethod.email;
        recipient = _emailController.text;
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid login method'),
            backgroundColor: Colors.red,
          ),
        );
        return;
    }

    try {
      await authProvider.sendVerificationCode(method, recipient);
      _startOTPTimer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send code: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _handleForgotPassword() {
    String recipient = '';

    if (_loginMethod == 'email' && _emailController.text.isNotEmpty) {
      recipient = _emailController.text;
    } else if (_loginMethod == 'username') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please use email or phone to reset password'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: const Text(
          'We will send you a password reset link to your registered email or phone number.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4D3E),
            ),
            onPressed: () {
              Navigator.pop(context);
              _sendPasswordResetLink(recipient);
            },
            child: const Text(
              'Send Link',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _sendPasswordResetLink(String recipient) async {
    final authProvider = context.read<AuthProvider>();

    try {
      await authProvider.sendPasswordResetLink(recipient);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password reset link sent! Check your email or phone.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/register');
          },
          child: const Text(
            'Sign up',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF1B4D3E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _clearControllers() {
    _emailController.clear();
    _phoneController.clear();
    _usernameController.clear();
    _passwordController.clear();
    _verificationCodeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _buildLogo(),
                    const SizedBox(height: 40),
                    _buildLoginMethodSelector(),
                    const SizedBox(height: 30),
                    Form(
                      key: _formKey,
                      child: _buildLoginForm(),
                    ),
                    const SizedBox(height: 20),
                    if (_loginMethod == 'username') _buildForgotPasswordLink(),
                    if (_loginMethod == 'username') const SizedBox(height: 20),
                    _buildLoginButton(authProvider.isLoading),
                    const SizedBox(height: 20),
                    _buildSignUpLink(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset(
          'assets/images/pieces/thiru_logo.png',
          width: 180,
          height: 180,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 180,
              height: 180,
              color: const Color(0xFF1B4D3E),
              child: const Icon(
                Icons.person,
                size: 90,
                color: Colors.white,
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Chess Princess',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFFDAA520),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildMethodTab('SMS', 'sms', Icons.sms_outlined),
          _buildMethodTab('WhatsApp', 'whatsapp', Icons.message_outlined),
          _buildMethodTab('Email', 'email', Icons.email_outlined),
          _buildMethodTab('Username', 'username', Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildMethodTab(String label, String value, IconData icon) {
    final isSelected = _loginMethod == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _loginMethod = value;
            _clearControllers();
            _isOTPSent = false;
            _otpCountdown = 0;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1B4D3E) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    switch (_loginMethod) {
      case 'sms':
        return _buildSMSForm();
      case 'whatsapp':
        return _buildWhatsAppForm();
      case 'email':
        return _buildEmailForm();
      case 'username':
        return _buildUsernameForm();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSMSForm() {
    return Column(
      children: [
        _buildPhoneTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: '9876543210',
          validator: Validators.validatePhone,
          showOTPButton: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _verificationCodeController,
          label: 'Verification Code',
          hint: 'Enter 6-digit code',
          prefixIcon: Icons.lock_outline,
          keyboardType: TextInputType.number,
          validator: Validators.validateVerificationCode,
        ),
      ],
    );
  }

  Widget _buildWhatsAppForm() {
    return Column(
      children: [
        _buildPhoneTextField(
          controller: _phoneController,
          label: 'WhatsApp Number',
          hint: '9876543210',
          validator: Validators.validatePhone,
          showOTPButton: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _verificationCodeController,
          label: 'Verification Code',
          hint: 'Enter code from WhatsApp',
          prefixIcon: Icons.lock_outline,
          keyboardType: TextInputType.number,
          validator: Validators.validateVerificationCode,
        ),
      ],
    );
  }

  Widget _buildPhoneTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    bool showOTPButton = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCountryCode,
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  items: _countryCodes.map((country) {
                    return DropdownMenuItem<String>(
                      value: country['code'],
                      child: Row(
                        children: [
                          Text(
                            country['flag']!,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            country['code']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCountryCode = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                validator: validator,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                  suffixIcon: showOTPButton ? _buildSendCodeButton() : null,
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1B4D3E), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'your.email@example.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          suffixWidget: _buildSendCodeButton(),
          validator: Validators.validateEmail,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _verificationCodeController,
          label: 'Verification Code',
          hint: 'Enter code from email',
          prefixIcon: Icons.lock_outline,
          keyboardType: TextInputType.number,
          validator: Validators.validateVerificationCode,
        ),
      ],
    );
  }

  Widget _buildUsernameForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _usernameController,
          label: 'Username',
          hint: 'Enter your username',
          prefixIcon: Icons.person_outline,
          validator: Validators.validateUsername,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Enter your password',
          prefixIcon: Icons.lock_outline,
          obscureText: !_isPasswordVisible,
          suffixWidget: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          validator: Validators.validatePassword,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixWidget,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(prefixIcon, color: Colors.grey),
            suffixIcon: suffixWidget,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1B4D3E), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendCodeButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton(
            onPressed: (_isOTPSent || authProvider.isLoading)
                ? null
                : _sendVerificationCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5BA896),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: _isOTPSent
                ? Text(
              '${_otpCountdown}s',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            )
                : authProvider.isLoading
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Text(
              'Get OTP',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: _handleForgotPassword,
        child: const Text(
          'Forgot password?',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF1B4D3E),
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B4D3E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          'LOGIN',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}