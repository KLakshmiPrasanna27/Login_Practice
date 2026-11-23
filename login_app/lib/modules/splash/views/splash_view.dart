import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';
import '../../../utils/app_colors.dart';

class SplashView extends GetView<SplashController> {

  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {

    // Initialize the splash controller
    final splashController = controller;

    return Scaffold(

      backgroundColor: AppColors.primary,

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            // Application Logo
            const Icon(
              Icons.account_circle,
              size: 120,
              color: Colors.white,
            ),

            const SizedBox(height: 25),

            // Application Name
            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'User Management Application',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 40),

            // Loading Indicator
            const CircularProgressIndicator(
              color: Colors.white,
            ),

            const SizedBox(height: 20),

            Text(
              splashController.isClosed
                  ? 'Please restart the application'
                  : 'Please wait...',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),

          ],
        ),
      ),
    );
  }
}