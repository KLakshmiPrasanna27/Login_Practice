import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/data/models/user_model.dart';
import '../../../app/data/repositories/auth_repository.dart';
import '../../../app/data/services/auth_service.dart';

// Home Controller
class HomeController extends GetxController {

  final AuthRepository _repository =
      AuthRepository(AuthService());

  // ================= OBSERVABLE VARIABLES =================

  var selectedIndex = 0.obs;
  var isLoading = false.obs;

  final currentUser = Rxn<UserModel>();

  // ================= PROFILE CONTROLLERS =================

  final profileFormKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // ================= INITIALIZATION =================

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  // ================= TAB NAVIGATION =================

  void changeTab(int index) {
    selectedIndex.value = index;
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

  // ================= SET PROFILE DATA =================

  void setProfileData(UserModel user) {

    currentUser.value = user;

    nameController.text = user.name;
    usernameController.text = user.username;
    emailController.text = user.email;
    phoneController.text = user.phone;

  }

  // ================= READ PROFILE =================

  Future<void> getProfile() async {

    if (isLoading.value) return;

    isLoading.value = true;

    try {

      final user = await _repository.getProfile();

      setProfileData(user);

    } catch (e) {

      showError(e);

    } finally {

      isLoading.value = false;

    }
  }

  // ================= UPDATE PROFILE =================

  Future<void> updateProfile() async {

    if (profileFormKey.currentState?.validate() != true ||
        isLoading.value) {
      return;
    }

    isLoading.value = true;

    try {

      final user = await _repository.updateProfile(
        name: nameController.text.trim(),
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
      );

      setProfileData(user);

      showSuccess('Profile updated successfully');

    } catch (e) {

      showError(e);

    } finally {

      isLoading.value = false;

    }
  }

  // ================= DELETE ACCOUNT =================

  Future<void> deleteAccount() async {

    if (isLoading.value) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? '
          'This action cannot be undone.',
        ),
        actions: [

          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),

          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),

        ],
      ),
    );

    if (confirmed != true || isLoading.value) return;

    isLoading.value = true;

    try {

      final result = await _repository.deleteAccount();

      if (result) {

        currentUser.value = null;

        Get.offAllNamed(AppRoutes.login);

        showSuccess('Account deleted successfully');

      } else {

        showError('Unable to delete account');

      }

    } catch (e) {

      showError(e);

    } finally {

      isLoading.value = false;

    }
  }

  // ================= LOGOUT =================

  Future<void> logout() async {

    if (isLoading.value) return;

    isLoading.value = true;

    try {

      await _repository.logout();

      currentUser.value = null;

      Get.offAllNamed(AppRoutes.login);

      showSuccess('Logged out successfully');

    } catch (e) {

      showError(e);

    } finally {

      isLoading.value = false;

    }
  }

  // ================= RELEASE RESOURCES =================

  @override
  void onClose() {

    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    super.onClose();

  }
}