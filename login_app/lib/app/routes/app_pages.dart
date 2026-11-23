import 'package:get/get.dart';
import 'app_routes.dart';
import '../../modules/splash/views/splash_view.dart';
import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/signup_view.dart';
import '../../modules/auth/views/otp_view.dart';
import '../../modules/auth/bindings/auth_binding.dart';

import '../../modules/home/views/home_view.dart';
import '../../modules/home/bindings/home_binding.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),

    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
  ];
}