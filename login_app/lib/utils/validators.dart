class Validators {

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your username';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
        .hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 6) {
      return 'Password must contain at least 6 characters';
    }

    return null;
  }

  static String? validateConfirmPassword(
      String? value, String password) {

    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter OTP';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Please enter a valid 6-digit OTP';
    }

    return null;
  }
}