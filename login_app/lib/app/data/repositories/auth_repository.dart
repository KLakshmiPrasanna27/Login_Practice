import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  // ================= REGISTER =================

  Future<UserModel> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String password,
  }) {
    return _authService.register(
      name: name,
      username: username,
      email: email,
      phone: phone,
      password: password,
    );
  }

  // ================= REQUEST LOGIN OTP =================

  Future<bool> requestLoginOtp({
    required String username,
    required String password,
    required String phone,
  }) {
    return _authService.requestLoginOtp(
      username: username,
      password: password,
      phone: phone,
    );
  }

  // ================= VERIFY OTP =================

  Future<UserModel> verifyOtp({required String phone, required String otp}) {
    return _authService.verifyOtp(phone: phone, otp: otp);
  }

  // ================= GET PROFILE =================

  Future<UserModel> getProfile() {
    return _authService.getProfile();
  }

  // ================= UPDATE PROFILE =================

  Future<UserModel> updateProfile({
    required String name,
    required String username,
    required String email,
    required String phone,
  }) {
    return _authService.updateProfile(
      name: name,
      username: username,
      email: email,
      phone: phone,
    );
  }

  // ================= DELETE ACCOUNT =================

  Future<bool> deleteAccount() {
    return _authService.deleteAccount();
  }

  // ================= LOGOUT =================

  Future<void> logout() {
    return _authService.logout();
  }
}
