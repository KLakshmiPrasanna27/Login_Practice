import 'package:get/get.dart';

import '../../../app/data/services/token_storage_service.dart';
import '../../../app/data/services/auth_service.dart';
import '../../../app/routes/app_routes.dart';

class SplashController extends GetxController {

  final TokenStorageService _tokenStorage =
      TokenStorageService();

  final AuthService _authService = AuthService();

  // Initialization
  @override
  void onReady() {
    super.onReady();
    checkSession();
  }

  // Check User Session
  Future<void> checkSession() async {

    await Future.delayed(
      const Duration(seconds: 2),
    );

    try {

      final token = await _tokenStorage.getToken();

      // Check whether token exists
      if (token == null || token.isEmpty) {

        Get.offAllNamed(AppRoutes.login);
        return;

      }

      // Validate token through backend
      await _authService.getProfile();

      // Valid session
      Get.offAllNamed(AppRoutes.home);

    } catch (e) {

      // Session could not be validated
      Get.offAllNamed(AppRoutes.login);

    }
  }
}