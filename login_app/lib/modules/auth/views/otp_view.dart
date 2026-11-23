import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/validators.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_button.dart';

class OtpView extends GetView<AuthController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('OTP Verification'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),

            child: Obx(
              () => controller.isOtpVerified.value
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.verified_user,
                          size: 100,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'OTP verified successfully.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 25),
                        AppButton(
                          text: 'Login',
                          onPressed: controller.completeLogin,
                        ),
                      ],
                    )
                  : Form(
                      key: controller.otpFormKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.verified_user,
                            size: 100,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Verify OTP',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Enter the 6-digit verification code',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            controller.phoneController.text,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          AppTextField(
                            controller: controller.otpController,
                            label: 'Enter OTP',
                            icon: Icons.lock,
                            keyboardType: TextInputType.number,
                            validator: Validators.validateOtp,
                          ),
                          const SizedBox(height: 25),
                          Obx(
                            () => controller.isLoading.value
                                ? const CircularProgressIndicator()
                                : AppButton(
                                    text: 'Verify OTP',
                                    onPressed: controller.verifyOtp,
                                  ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Didn't receive OTP?"),
                              Obx(
                                () => TextButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : controller.resendOtp,
                                  child: const Text(
                                    'Resend OTP',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
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
        ),
      ),
    );
  }
}
