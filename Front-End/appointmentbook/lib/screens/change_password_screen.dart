import 'package:appointmentbook/repositories/auth_repository.dart';
import 'package:appointmentbook/services/auth_api_service.dart';
import 'package:appointmentbook/validation/validator.dart';
import 'package:appointmentbook/widget/build_requirement.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, required this.email});

  final String email;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // ============================================================
  // Controllers
  // ============================================================

  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ============================================================
  // State
  // ============================================================

  bool _obscurePassword = true;

  // ============================================================
  // Save Password
  // ============================================================

  Future<void> _savePassword() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authApiService = AuthApiService();

    final authRepository = AuthRepository(apiService: authApiService);

    try {
      final result = await authRepository.changePassword(
        email: widget.email,
        newPassword: _passwordController.text,
      );

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // go to Home
      }
    } catch (e) {
      print(e);
    }
  }

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final validator = Validators(password: _passwordController.text);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // ========================================================
      // App Bar
      // ========================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF1E293B),
          ),
        ),

        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        centerTitle: true,
      ),

      // ========================================================
      // Body
      // ========================================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // Header Illustration
                // ==================================================
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F0FE),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1264E8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // Title
                // ==================================================
                const Center(
                  child: Text(
                    'Create a new password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // Description
                // ==================================================
                const Center(
                  child: Text(
                    'Choose a strong password to keep your account secure.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ==================================================
                // New Password Label
                // ==================================================
                const Text(
                  'New password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // Password Field
                // ==================================================
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,

                  onChanged: (_) {
                    setState(() {});
                  },

                  validator: (value) => Validators.passwordValidate(value),

                  decoration: InputDecoration(
                    hintText: 'Enter your new password',

                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF64748B),
                    ),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF64748B),
                      ),
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 17,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF1264E8),
                        width: 1.5,
                      ),
                    ),

                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFEF4444)),
                    ),

                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // Password Strength
                // ==================================================
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: validator.passwordStrength,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF1264E8),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        validator.passwordStrengthText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 22),

                // ==================================================
                // Password Requirements
                // ==================================================
                const Text(
                  'Password requirements',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),

                const SizedBox(height: 12),

                BuildRequirement(
                  text: 'At least 8 characters',
                  isValid: validator.hasMinLength,
                ),

                BuildRequirement(
                  text: 'One uppercase letter',
                  isValid: validator.hasUppercase,
                ),

                BuildRequirement(
                  text: 'One lowercase letter',
                  isValid: validator.hasLowercase,
                ),

                BuildRequirement(
                  text: 'One number',
                  isValid: validator.hasNumber,
                ),

                BuildRequirement(
                  text: 'One special character',
                  isValid: validator.hasSpecialCharacter,
                ),

                const SizedBox(height: 34),

                // ==================================================
                // SAVE BUTTON
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _savePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1264E8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Save Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // Security Information
                // ==================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),

                    const SizedBox(width: 7),

                    Text(
                      'Your password is securely protected',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
