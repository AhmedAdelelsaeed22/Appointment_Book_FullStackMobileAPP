import 'package:flutter/material.dart';

class Validators {
  final String password;

  Validators({this.password = ''});

  // ------------------------------------------------------------
  // Password requirements
  // ------------------------------------------------------------

  bool get hasMinLength {
    return password.length >= 8;
  }

  bool get hasUppercase {
    return RegExp(r'[A-Z]').hasMatch(password);
  }

  bool get hasLowercase {
    return RegExp(r'[a-z]').hasMatch(password);
  }

  bool get hasNumber {
    return RegExp(r'[0-9]').hasMatch(password);
  }

  bool get hasSpecialCharacter {
    return RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]]').hasMatch(password);
  }

  bool get isPasswordValid {
    return hasMinLength &&
        hasUppercase &&
        hasLowercase &&
        hasNumber &&
        hasSpecialCharacter;
  }

  // ------------------------------------------------------------
  // Name
  // ------------------------------------------------------------

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must contain at least 2 characters';
    }

    return null;
  }

  // ------------------------------------------------------------
  // Email
  // ------------------------------------------------------------

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  double get passwordStrength {
    if (password.isEmpty) {
      return 0;
    }

    int score = 0;

    if (hasMinLength) score++;
    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasNumber) score++;
    if (hasSpecialCharacter) score++;

    return score / 5;
  }

  String get passwordStrengthText {
    final strength = passwordStrength;

    if (strength == 0) {
      return '';
    }

    if (strength <= 0.4) {
      return 'Weak password';
    }

    if (strength <= 0.6) {
      return 'Medium password';
    }

    if (strength <= 0.8) {
      return 'Good password';
    }

    return 'Strong password';
  }

  // ------------------------------------------------------------
  // Phone
  // ------------------------------------------------------------

  static String? validatePhone(String? value) {
    if (value != null) {
      final phoneRegex = RegExp(r'^[0-9+\-\s()]{8,20}$');

      if (!phoneRegex.hasMatch(value.trim())) {
        return 'Enter a valid phone number';
      }
    }

    return null;
  }

  // ------------------------------------------------------------
  // Password
  // ------------------------------------------------------------

  static String? passwordValidate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    final validator = Validators(password: value);

    if (!validator.hasMinLength) {
      return 'Password must contain at least 8 characters';
    }

    if (!validator.hasUppercase) {
      return 'Password must contain an uppercase letter';
    }

    if (!validator.hasLowercase) {
      return 'Password must contain a lowercase letter';
    }

    if (!validator.hasNumber) {
      return 'Password must contain a number';
    }

    if (!validator.hasSpecialCharacter) {
      return 'Password must contain a special character';
    }

    return null;
  }

  // ------------------------------------------------------------
  // Confirm password
  // ------------------------------------------------------------

  static String? validateConfirmPassword(
    String? value,
    TextEditingController passwordController,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }
}
