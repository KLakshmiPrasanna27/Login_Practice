import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:login_app/app/routes/app_pages.dart';
import 'package:login_app/app/routes/app_routes.dart';
import 'package:login_app/app/data/models/user_model.dart';
import 'package:login_app/modules/auth/controllers/auth_controller.dart';

void main() {
  testWidgets('login screen builds with material localizations', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        initialRoute: AppRoutes.login,
        getPages: AppPages.routes,
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Mobile Number'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
  });

  testWidgets('verified OTP shows confirmation and Login button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        initialRoute: AppRoutes.otp,
        getPages: AppPages.routes,
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    final controller = Get.find<AuthController>();
    controller.currentUser.value = UserModel(
      name: 'Test User',
      username: 'test_user',
      email: 'test@example.com',
      phone: '1234567890',
    );
    controller.isOtpVerified.value = true;
    await tester.pump();

    expect(find.text('OTP verified successfully.'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Verify OTP'), findsNothing);
  });
}
