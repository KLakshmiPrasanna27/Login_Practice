import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/validators.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_button.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // User Icon
                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: AppColors.primary,
                ),

                const SizedBox(height: 15),

                // Welcome Message
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Login to your account',
                  style: TextStyle(fontSize: 16, color: AppColors.grey),
                ),

                const SizedBox(height: 30),

                // Login Form
                Form(
                  key: controller.loginFormKey,

                  child: Column(
                    children: [
                      // Username
                      AppTextField(
                        controller: controller.usernameController,
                        label: 'Username',
                        icon: Icons.person,
                        validator: Validators.validateUsername,
                      ),

                      const SizedBox(height: 18),

                      // Password
                      Obx(
                        () => AppTextField(
                          controller: controller.passwordController,
                          label: 'Password',
                          icon: Icons.lock,
                          obscureText: controller.isPasswordHidden.value,
                          validator: Validators.validatePassword,

                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: controller.togglePassword,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Phone Number
                      AppTextField(
                        controller: controller.phoneController,
                        label: 'Mobile Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: Validators.validatePhone,
                      ),

                      const SizedBox(height: 20),

                      // Request OTP Button
                      Obx(
                        () => controller.isLoading.value
                            ? const CircularProgressIndicator()
                            : AppButton(
                                text: 'Send OTP',
                                onPressed: controller.sendOtp,
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Signup Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),

                    TextButton(
                      onPressed: () {
                        if (!controller.isLoading.value) {
                          Get.toNamed(AppRoutes.signup);
                        }
                      },

                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
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
