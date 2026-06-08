import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/device_token_service.dart';
import '../services/fcm_service.dart';
import '../services/token_storage_service.dart';
import '../widgets/login/login_button.dart';
import '../widgets/login/login_error_box.dart';
import '../widgets/login/login_header.dart';
import '../widgets/login/login_text_field.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? initialMessage;

  const LoginScreen({
    super.key,
    this.initialMessage,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final FcmService _fcmService = FcmService();
  final DeviceTokenService _deviceTokenService = DeviceTokenService();
  final TokenStorageService _tokenStorageService = TokenStorageService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      _errorMessage = widget.initialMessage;
    }
  }

  String _getReadableErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email ve şifre boş olamaz.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final accessToken = await _authService.login(
        email: email,
        password: password,
      );

      final fcmToken = await _fcmService.getFcmToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        throw Exception('FCM token alınamadı.');
      }

      await _deviceTokenService.registerDeviceToken(
        accessToken: accessToken,
        fcmToken: fcmToken,
      );

      await _tokenStorageService.saveAccessToken(accessToken);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = _getReadableErrorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Card(
                elevation: 8,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LoginHeader(),
                      const SizedBox(height: 26),

                      LoginTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 14),

                      LoginTextField(
                        controller: _passwordController,
                        label: 'Şifre',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (!_isLoading) {
                            _login();
                          }
                        },
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (_errorMessage != null)
                        LoginErrorBox(
                          message: _errorMessage!,
                        ),

                      LoginButton(
                        isLoading: _isLoading,
                        onPressed: _login,
                      ),

                      const SizedBox(height: 18),

                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'v1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}