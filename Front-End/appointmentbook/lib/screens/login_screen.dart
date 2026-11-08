import 'package:appointmentbook/models/google_login_request.dart';
import 'package:appointmentbook/models/login_response.dart';
import 'package:appointmentbook/providers/user_provider.dart';
import 'package:appointmentbook/repositories/auth_repository.dart';
import 'package:appointmentbook/screens/home_screen.dart';
import 'package:appointmentbook/screens/otp_verification_screen.dart';
import 'package:appointmentbook/screens/sign_up_screen.dart';
import 'package:appointmentbook/services/auth_api_service.dart';
import 'package:appointmentbook/services/google_auth_service.dart';
import 'package:appointmentbook/storage/token_storage.dart';
import 'package:appointmentbook/validation/validator.dart';
import 'package:appointmentbook/widget/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // ============================================================
  // FORM
  // ============================================================

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  late AuthApiService authApiService;
  late AuthRepository authRepository;
  late TokenStorage tokenStorage;

  @override
  void initState() {
    super.initState();
    authApiService = AuthApiService();
    authRepository = AuthRepository(apiService: authApiService);
    tokenStorage = TokenStorage();
  }

  // ============================================================
  // VARIABLES
  // ============================================================

  bool obscurePassword = true;
  bool _isLoading = false;
  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // Actions
  // ============================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Login
      final response = await authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response == null) {
        throw Exception('Login failed');
      }

      // 2. Save AppointmentBook tokens
      await tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      await tokenStorage.saveEmail(emailController.text.trim());

      // 3. Load user from backend
      await ref
          .read(userProvider.notifier)
          .loadUser(
            email: emailController.text.trim(),
            accessToken: response.accessToken,
          );

      // 4. Get loaded user
      final user = ref.read(userProvider).value;

      if (user == null) {
        throw Exception('Failed to load user information');
      }

      if (!mounted) {
        return;
      }

      // 5. Go to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e, stackTrace) {
      debugPrint('LOGIN ERROR: $e');
      debugPrint('LOGIN STACK TRACE: $stackTrace');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleAuthService googleAuthService = GoogleAuthService();

      // 1. Sign in with Google
      final googleAccount = await googleAuthService.signIn();

      if (googleAccount == null) {
        return;
      }

      // 2. Send Google's ID token to AppointmentBook backend
      final request = GoogleLoginRequest(idToken: googleAccount.idToken);

      final LoginResponse? response = await authRepository.loginWithGoogle(
        request,
      );

      if (response == null) {
        return;
      }

      // 3. Store AppointmentBook tokens
      await tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await tokenStorage.saveEmail(emailController.text.trim());
      // 4. Load the AppointmentBook user
      await ref
          .read(userProvider.notifier)
          .loadUser(
            email: googleAccount.email,
            accessToken: response.accessToken,
          );

      // 5. Get the loaded user
      final user = ref.read(userProvider).value;

      if (user == null) {
        throw Exception('Failed to load user information');
      }

      if (!mounted) return;

      // 6. Go to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e, stackTrace) {
      debugPrint('GOOGLE LOGIN ERROR: $e');
      debugPrint('GOOGLE LOGIN STACK TRACE: $stackTrace');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google login failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _otpScreen() {
    if (emailController.text.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please write your email address"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OtpVerificationScreen(email: emailController.text.trim()),
      ),
    );
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
              // ============================================================
              // HEADER
              // ============================================================
              const Header(),

              // ============================================================
              // FORM
              // ============================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 28),

                      // ==================================================
                      // TITLE
                      // ==================================================
                      const Center(
                        child: Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==================================================
                      // EMAIL LABEL
                      // ==================================================
                      const Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1264E8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ==================================================
                      // EMAIL
                      // ==================================================
                      TextFormField(
                        controller: emailController,

                        keyboardType: TextInputType.emailAddress,

                        textInputAction: TextInputAction.next,

                        validator: (value) => Validators.validateEmail(value),

                        decoration: const InputDecoration(
                          hintText: 'Enter your email',

                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ==================================================
                      // PASSWORD LABEL
                      // ==================================================
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1264E8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ==================================================
                      // PASSWORD
                      // ==================================================
                      TextFormField(
                        controller: passwordController,

                        obscureText: obscurePassword,

                        textInputAction: TextInputAction.done,

                        validator: (value) =>
                            Validators.passwordValidate(value),

                        decoration: InputDecoration(
                          hintText: 'Enter your password',

                          prefixIcon: const Icon(Icons.lock_outline, size: 20),

                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },

                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      // ==================================================
                      // FORGOT PASSWORD
                      // ==================================================
                      Align(
                        alignment: Alignment.centerRight,

                        child: TextButton(
                          onPressed: _otpScreen,

                          child: const Text('Forgot Password?'),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ==================================================
                      // LOGIN BUTTON
                      // ==================================================
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Login'),
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // OR
                      // ==================================================
                      Row(
                        children: [
                          const Expanded(child: Divider()),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),

                            child: Text(
                              'OR',

                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ),

                          const Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // SOCIAL LOGIN
                      // ==================================================
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _loginWithGoogle,
                          icon: const Icon(Icons.g_mobiledata, size: 30),

                          label: const Text('Google'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              4,
                              52,
                              130,
                            ),
                            foregroundColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              217,
                            ),
                            minimumSize: const Size(0, 52),
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // REGISTER
                      // ==================================================
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                            ),

                            children: [
                              const TextSpan(text: "Don't have an account? "),

                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpScreen(),
                                      ),
                                    );
                                  },

                                  child: const Text(
                                    'Create One',
                                    style: TextStyle(
                                      color: Color(0xFF1264E8),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
