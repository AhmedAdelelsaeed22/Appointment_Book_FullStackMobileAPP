import 'dart:io';
import 'package:appointmentbook/repositories/auth_repository.dart';
import 'package:appointmentbook/services/auth_api_service.dart';
import 'package:appointmentbook/validation/validator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Focus nodes
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // Pick image
  // ------------------------------------------------------------

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (image == null) {
        return;
      }

      setState(() {
        _selectedImage = File(image.path);
      });
    } catch (e) {
      debugPrint('Image picker error: $e');

      if (!mounted) return;

      _showMessage('Unable to select image: $e', isError: true);
    }
  }

  // ------------------------------------------------------------
  // Sign up
  // ------------------------------------------------------------

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authApiService = AuthApiService();

    final authRepository = AuthRepository(apiService: authApiService);

    try {
      final result = await authRepository.signUp(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        profileImageUrl: _selectedImage?.path,
      );

      await Future.delayed(const Duration(seconds: 1));

      if (result) {
        if (!mounted) return;

        _showMessage('Account created successfully!');

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage('Registration failed. Please try again.', isError: true);
      print('$e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // Message
  // ------------------------------------------------------------

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? Colors.red.shade700
            : const Color(0xFF1264E8),
      ),
    );
  }

  // ------------------------------------------------------------
  // Build
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final passwordValidator = Validators(password: _passwordController.text);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        title: const Text(
          'Create Account',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        centerTitle: true,

        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                const SizedBox(height: 24),

                _buildProfileImage(),

                const SizedBox(height: 28),

                // First + Last name
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _firstNameController,
                        focusNode: _firstNameFocus,
                        nextFocusNode: _lastNameFocus,
                        label: 'First name',
                        hint: 'John',
                        icon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        validator: Validators.validateName,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildTextField(
                        controller: _lastNameController,
                        focusNode: _lastNameFocus,
                        nextFocusNode: _emailFocus,
                        label: 'Last name',
                        hint: 'Doe',
                        icon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        validator: Validators.validateName,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Email
                _buildTextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  nextFocusNode: _phoneFocus,
                  label: 'Email',
                  hint: 'example@email.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateEmail,
                ),

                const SizedBox(height: 18),

                // Phone
                _buildTextField(
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  nextFocusNode: _passwordFocus,
                  label: 'Phone',
                  hint: '+20 100 000 0000',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validatePhone,
                ),

                const SizedBox(height: 18),

                // Password
                _buildPasswordField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  nextFocusNode: _confirmPasswordFocus,
                  label: 'Password',
                  isVisible: _isPasswordVisible,
                  onVisibilityChanged: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  validator: Validators.passwordValidate,
                ),

                const SizedBox(height: 12),

                // Password requirements
                _buildPasswordRequirements(passwordValidator),

                const SizedBox(height: 18),

                // Confirm password
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocus,
                  label: 'Confirm password',
                  isVisible: _isConfirmPasswordVisible,
                  onVisibilityChanged: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  validator: (value) {
                    return Validators.validateConfirmPassword(
                      value,
                      _passwordController,
                    );
                  },
                ),

                const SizedBox(height: 28),

                // Sign up button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1264E8),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF9DBCEB),
                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 22),

                // Login
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFF1264E8),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ------------------------------------------------------------
  // Header
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create your account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),

        SizedBox(height: 8),

        Text(
          'Join Appointment Book and manage your appointments easily.',
          style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // Profile image
  // ------------------------------------------------------------

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEFF6FF),
              border: Border.all(color: const Color(0xFFD6E7FF), width: 2),
            ),
            child: ClipOval(
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                  : const Icon(
                      Icons.person_outline,
                      size: 52,
                      color: Color(0xFF1264E8),
                    ),
            ),
          ),

          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF1264E8),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Normal text field
  // ------------------------------------------------------------

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputAction textInputAction,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,

      keyboardType: keyboardType,

      textInputAction: textInputAction,

      validator: validator,

      onFieldSubmitted: (_) {
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        }
      },

      style: const TextStyle(fontSize: 15, color: Color(0xFF1F2937)),

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        prefixIcon: Icon(icon, color: const Color(0xFF64748B)),

        filled: true,
        fillColor: const Color(0xFFF8FAFC),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1264E8), width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Password field
  // ------------------------------------------------------------

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityChanged,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,

      obscureText: !isVisible,

      textInputAction: nextFocusNode != null
          ? TextInputAction.next
          : TextInputAction.done,

      validator: validator,

      onChanged: (_) {
        setState(() {});
      },

      onFieldSubmitted: (_) {
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        }
      },

      style: const TextStyle(fontSize: 15, color: Color(0xFF1F2937)),

      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter your password',

        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B)),

        suffixIcon: IconButton(
          onPressed: onVisibilityChanged,
          icon: Icon(
            isVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFF64748B),
          ),
        ),

        filled: true,
        fillColor: const Color(0xFFF8FAFC),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1264E8), width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Password requirements
  // ------------------------------------------------------------

  Widget _buildPasswordRequirements(Validators validator) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password requirements',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),

          const SizedBox(height: 10),

          _buildRequirement('At least 8 characters', validator.hasMinLength),

          _buildRequirement('One uppercase letter', validator.hasUppercase),

          _buildRequirement('One lowercase letter', validator.hasLowercase),

          _buildRequirement('One number', validator.hasNumber),

          _buildRequirement(
            'One special character',
            validator.hasSpecialCharacter,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),

      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            size: 17,
            color: isValid ? Colors.green : const Color(0xFF94A3B8),
          ),

          const SizedBox(width: 8),

          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isValid ? Colors.green.shade700 : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
