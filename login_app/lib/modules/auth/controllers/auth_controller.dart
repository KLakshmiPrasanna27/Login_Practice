import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../app/data/models/user_model.dart';
import '../../../app/data/repositories/auth_repository.dart';
import '../../../app/data/services/auth_service.dart';
import '../../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _repository = AuthRepository(AuthService());

  // ================= FORM KEYS =================

  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();
  final otpFormKey = GlobalKey<FormState>();

  // ================= LOGIN CONTROLLERS =================

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  // ================= SIGNUP CONTROLLERS =================

  final nameController = TextEditingController();
  final signupUsernameController = TextEditingController();
  final emailController = TextEditingController();
  final signupPhoneController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ================= OTP CONTROLLER =================

  final otpController = TextEditingController();

  String? _otpPhone;

  // ================= OBSERVABLE VARIABLES =================

  var isPasswordHidden = true.obs;
  var isSignupPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;
  var isOtpVerified = false.obs;

  final currentUser = Rxn<UserModel>();

  // ================= PASSWORD VISIBILITY =================

  void togglePassword() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleSignupPassword() {
    isSignupPasswordHidden.value = !isSignupPasswordHidden.value;
  }

  void toggleConfirmPassword() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  // ================= SUCCESS MESSAGE =================

  void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // ================= ERROR MESSAGE =================

  void showError(Object error) {
    Get.snackbar(
      'Error',
      error.toString().replaceFirst('Exception: ', ''),
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // ================= SIGNUP =================

  Future<void> signup() async {
    if (signupFormKey.currentState?.validate() != true || isLoading.value) {
      return;
    }

    if (signupPasswordController.text != confirmPasswordController.text) {
      showError('Passwords do not match');
      return;
    }

    isLoading.value = true;

    try {
      await _repository.register(
        name: nameController.text.trim(),
        username: signupUsernameController.text.trim(),
        email: emailController.text.trim(),
        phone: signupPhoneController.text.trim(),
        password: signupPasswordController.text,
      );

      nameController.clear();
      signupUsernameController.clear();
      emailController.clear();
      signupPhoneController.clear();
      signupPasswordController.clear();
      confirmPasswordController.clear();

      Get.back();

      showSuccess('Registration successful');
    } catch (e) {
      showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ================= SEND OTP =================

  Future<void> sendOtp() async {
    if (loginFormKey.currentState?.validate() != true || isLoading.value) {
      return;
    }

    isLoading.value = true;
    isOtpVerified.value = false;

    try {
      final phone = phoneController.text.trim();

      final result = await _repository.requestLoginOtp(
        username: usernameController.text.trim(),
        password: passwordController.text,
        phone: phone,
      );

      if (result) {
        _otpPhone = phone;

        otpController.clear();

        Get.toNamed(AppRoutes.otp);

        showSuccess('OTP generated. Check the backend terminal.');
      } else {
        showError('Unable to send OTP');
      }
    } catch (e) {
      showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ================= VERIFY OTP =================

  Future<void> verifyOtp() async {
    if (otpFormKey.currentState?.validate() != true || isLoading.value) {
      return;
    }

    final phone = _otpPhone;

    if (phone == null) {
      showError('Please request an OTP first');
      return;
    }

    isLoading.value = true;

    try {
      final user = await _repository.verifyOtp(
        phone: phone,
        otp: otpController.text.trim(),
      );

      currentUser.value = user;

      usernameController.clear();
      passwordController.clear();
      otpController.clear();
      _otpPhone = null;
      isOtpVerified.value = true;
    } catch (e) {
      showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void completeLogin() {
    if (!isOtpVerified.value || currentUser.value == null) {
      showError('Please verify your OTP first');
      return;
    }

    phoneController.clear();
    Get.offAllNamed(AppRoutes.home);
    showSuccess('Login successful');
  }

  // ================= RESEND OTP =================

  Future<void> resendOtp() async {
    if (isLoading.value) {
      return;
    }

    final phone = _otpPhone;

    if (phone == null) {
      showError('Please request an OTP first');
      return;
    }

    isLoading.value = true;

    try {
      final result = await _repository.requestLoginOtp(
        username: usernameController.text.trim(),
        password: passwordController.text,
        phone: phone,
      );

      if (result) {
        otpController.clear();

        showSuccess('New OTP generated. Check the backend terminal.');
      } else {
        showError('Unable to resend OTP');
      }
    } catch (e) {
      showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ================= RELEASE RESOURCES =================

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    phoneController.dispose();

    nameController.dispose();
    signupUsernameController.dispose();
    emailController.dispose();
    signupPhoneController.dispose();
    signupPasswordController.dispose();
    confirmPasswordController.dispose();

    otpController.dispose();

    super.onClose();
  }
}
