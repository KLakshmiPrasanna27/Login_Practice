
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/validators.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_button.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Registration'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),

          child: Form(
            key: controller.signupFormKey,

            child: Column(
              children: [

                // Registration Icon
                const Icon(
                  Icons.person_add_alt_1,
                  size: 85,
                  color: AppColors.primary,
                ),

                const SizedBox(height: 15),

                // Heading
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Enter your details to register',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                // Full Name
                AppTextField(
                  controller: controller.nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                  validator: Validators.validateName,
                ),

                const SizedBox(height: 18),

                // Username
                AppTextField(
                  controller: controller.signupUsernameController,
                  label: 'Username',
                  icon: Icons.account_circle,
                  validator: Validators.validateUsername,
                ),

                const SizedBox(height: 18),

                // Email
                AppTextField(
                  controller: controller.emailController,
                  label: 'Email Address',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),

                const SizedBox(height: 18),

                // Mobile Number
                AppTextField(
                  controller: controller.signupPhoneController,
                  label: 'Mobile Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),

                const SizedBox(height: 18),

                // Password
                Obx(
                  () => AppTextField(
                    controller: controller.signupPasswordController,
                    label: 'Password',
                    icon: Icons.lock,
                    obscureText:
                        controller.isSignupPasswordHidden.value,
                    validator: Validators.validatePassword,

                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isSignupPasswordHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: controller.toggleSignupPassword,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Confirm Password
                Obx(
                  () => AppTextField(
                    controller: controller.confirmPasswordController,
                    label: 'Confirm Password',
                    icon: Icons.lock_outline,
                    obscureText:
                        controller.isConfirmPasswordHidden.value,

                    validator: (value) {
                      return Validators.validateConfirmPassword(
                        value,
                        controller.signupPasswordController.text,
                      );
                    },

                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: controller.toggleConfirmPassword,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Signup Button
                Obx(
                  () => controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : AppButton(
                          text: 'Sign Up',
                          onPressed: controller.signup,
                        ),
                ),

                const SizedBox(height: 20),

                // Login Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Text('Already have an account?'),

                    TextButton(
                      onPressed: () {
                        if (!controller.isLoading.value) {
                          Get.back();
                        }
                      },
                      child: const Text(
                        'Login',
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
