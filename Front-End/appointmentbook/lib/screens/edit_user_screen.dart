import 'package:flutter/material.dart';

import 'package:appointmentbook/models/user_model.dart';
import 'package:appointmentbook/repositories/user_repository.dart';
import 'package:appointmentbook/services/user_api_service.dart';
import 'package:appointmentbook/exceptions/unauthorized_exception.dart';

class EditUserScreen extends StatefulWidget {
  final UserModel user;
  final String accessToken;

  const EditUserScreen({
    super.key,
    required this.user,
    required this.accessToken,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  // ============================================================
  // REPOSITORY
  // ============================================================

  late final UserRepository _userRepository;

  // ============================================================
  // FORM
  // ============================================================

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _imageController;

  bool _isLoading = false;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    _userRepository = UserRepository(UserApiService());

    _firstNameController = TextEditingController(text: widget.user.firstName);

    _lastNameController = TextEditingController(text: widget.user.lastName);

    _emailController = TextEditingController(text: widget.user.email);

    _phoneController = TextEditingController(text: widget.user.phone ?? '');

    _imageController = TextEditingController(text: widget.user.image ?? '');
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _imageController.dispose();

    super.dispose();
  }

  // ============================================================
  // UPDATE USER
  // ============================================================

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated UserModel
      final updatedUser = UserModel(
        userId: widget.user.userId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),

        // Do not send the existing password hash.
        // Empty password means no password change.
        password: '',

        image: _imageController.text.trim().isEmpty
            ? null
            : _imageController.text.trim(),

        // Preserve existing account information.
        isActive: widget.user.isActive,
        createAt: widget.user.createAt,
        userRole: widget.user.userRole,
      );

      // Call repository
      final result = await _userRepository.updateUser(
        widget.user.userId,
        updatedUser,
        widget.accessToken,
      );

      if (!mounted) return;

      // Return updated user to previous screen
      Navigator.pop(context, result);
    } on UnauthorizedException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
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

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1264E8)),
          filled: true,
          fillColor: Colors.grey.withValues(alpha: 0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1264E8), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1264E8);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =================================================
                // PROFILE HEADER
                // =================================================
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        backgroundImage:
                            widget.user.image != null &&
                                widget.user.image!.isNotEmpty
                            ? NetworkImage(widget.user.image!)
                            : null,
                        child:
                            widget.user.image == null ||
                                widget.user.image!.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 55,
                                color: primaryColor,
                              )
                            : null,
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Update your personal information',
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // =================================================
                // PERSONAL INFORMATION
                // =================================================
                const Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 18),

                _buildTextField(
                  label: 'First Name',
                  icon: Icons.person_outline,
                  controller: _firstNameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }

                    return null;
                  },
                ),

                _buildTextField(
                  label: 'Last Name',
                  icon: Icons.person_outline,
                  controller: _lastNameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name is required';
                    }

                    return null;
                  },
                ),

                _buildTextField(
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }

                    if (!RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }

                    return null;
                  },
                ),

                _buildTextField(
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 10),

                // =================================================
                // PROFILE IMAGE
                // =================================================
                const Text(
                  'Profile Image',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 18),

                _buildTextField(
                  label: 'Profile Image URL',
                  icon: Icons.image_outlined,
                  controller: _imageController,
                  keyboardType: TextInputType.url,
                ),

                const SizedBox(height: 15),

                // =================================================
                // SAVE BUTTON
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateUser,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: primaryColor.withValues(
                        alpha: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
