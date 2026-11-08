import 'dart:async';
import 'package:appointmentbook/repositories/auth_repository.dart';
import 'package:appointmentbook/screens/change_password_screen.dart';
import 'package:appointmentbook/services/auth_api_service.dart';
import 'package:appointmentbook/widget/build_otp_box.dart';
import 'package:appointmentbook/widget/header.dart';
import 'package:flutter/material.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  // ============================================================
  // FOCUS NODES
  // ============================================================

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late AuthApiService authApiService;

  late AuthRepository authRepository;

  // ============================================================
  // FORM KEY
  // ============================================================

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ============================================================
  // TIMER
  // ============================================================

  Timer? _timer;

  int _remainingSeconds = 60;

  bool _canResend = false;

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();
    authApiService = AuthApiService();
    authRepository = AuthRepository(apiService: authApiService);
    _sendOTP();
    _startTimer();
  }

  Future<void> _sendOTP() async {
    try {
      final result = await authRepository.sendOTP(email: widget.email);
      if (result) {
        _showMessage('Send Code For You');
      }
    } catch (e) {
      print(e);
    }
  }

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _remainingSeconds = 60;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });

        timer.cancel();
      }
    });
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<void> _verifyOtp() async {
    final otp = _getOtp();

    if (otp.length != 6) {
      _showMessage('Please enter the 6-digit verification code.');

      return;
    }

    try {
      final result = await authRepository.otpVerification(
        email: widget.email,
        otp: otp,
      );

      if (result) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChangePasswordScreen(email: widget.email),
          ),
        );
      }
    } catch (e) {
      print(e);
      _showMessage('Code is not correct');
    }
  }

  // ============================================================
  // GET OTP
  // ============================================================

  String _getOtp() {
    return _controllers.map((controller) => controller.text).join();
  }

  // ============================================================
  // RESEND OTP
  // ============================================================

  void _resendOtp() {
    if (!_canResend) {
      return;
    }

    _sendOTP();

    _clearOtp();

    _startTimer();

    _showMessage('A new verification code has been sent.');
  }

  // ============================================================
  // CLEAR OTP
  // ============================================================

  void _clearOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }

    _focusNodes[0].requestFocus();
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ========================================================
              // HEADER
              // ========================================================
              const Header(),

              // ========================================================
              // CONTENT
              // ========================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),

                child: Form(
                  key: _formKey,

                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      // ==================================================
                      // TITLE
                      // ==================================================
                      const Text(
                        'VERIFY OTP',

                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ==================================================
                      // DESCRIPTION
                      // ==================================================
                      const Text(
                        'Enter the 6-digit verification code',
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'sent to ${widget.email}',

                        textAlign: TextAlign.center,

                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1264E8),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // OTP BOXES
                      // ==================================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: List.generate(6, (index) {
                          return BuildOtpBox(
                            index: index,
                            focusNodes: _focusNodes,
                            controllers: _controllers,
                          );
                        }),
                      ),

                      const SizedBox(height: 32),

                      // ==================================================
                      // VERIFY BUTTON
                      // ==================================================
                      SizedBox(
                        width: double.infinity,
                        height: 52,

                        child: ElevatedButton(
                          onPressed: _verifyOtp,

                          child: const Text('VERIFY'),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // RESEND TEXT
                      // ==================================================
                      if (!_canResend)
                        Text(
                          'Resend code in $_remainingSeconds seconds',

                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),

                      // ==================================================
                      // RESEND BUTTON
                      // ==================================================
                      if (_canResend)
                        TextButton(
                          onPressed: _resendOtp,

                          child: const Text('Resend Code'),
                        ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // CHANGE EMAIL
                      // ==================================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          const Text(
                            'Wrong email? ',

                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },

                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),

                            child: const Text('Change Email'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
