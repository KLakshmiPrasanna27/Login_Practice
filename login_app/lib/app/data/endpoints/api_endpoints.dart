class ApiEndpoints {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Authentication
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';

  // OTP Authentication
  static const String verifyOtp = '$baseUrl/otp/verify';

  // Profile CRUD Operations
  static const String getProfile = '$baseUrl/users/profile';
  static const String updateProfile = '$baseUrl/users/profile';
  static const String deleteAccount = '$baseUrl/users/profile';
}
