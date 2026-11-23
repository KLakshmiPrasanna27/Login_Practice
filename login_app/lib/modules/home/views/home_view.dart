import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../../utils/app_colors.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {

    final List<String> titles = [
      'Home',
      'About',
      'Profile',
      'Settings',
    ];

    final List<Widget> pages = [

      // Home Page
      buildHomePage(),

      // About Page
      buildPage(
        Icons.info,
        'About Us',
        'Welcome to our Flutter application.',
      ),

      // Profile Page
      buildProfilePage(),

      // Settings Page
      buildPage(
        Icons.settings,
        'Settings',
        'Manage your application settings.',
      ),
    ];

    return Obx(
      () => Scaffold(

        backgroundColor: AppColors.background,

        // ================= APP BAR =================

        appBar: AppBar(
          title: Text(
            titles[controller.selectedIndex.value],
          ),

          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,

          actions: [

            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',

              onPressed: () {
                Get.defaultDialog(
                  title: 'Logout',

                  middleText:
                      'Are you sure you want to logout?',

                  textConfirm: 'Yes',
                  textCancel: 'Cancel',

                  confirmTextColor: Colors.white,
                  buttonColor: AppColors.primary,
                  cancelTextColor: AppColors.primary,

                  onConfirm: () {
                    Get.back();
                    controller.logout();
                  },
                );
              },
            ),
          ],
        ),

        // ================= SELECTED PAGE =================

        body: pages[controller.selectedIndex.value],

        // ================= BOTTOM NAVIGATION =================

        bottomNavigationBar: BottomNavigationBar(

          currentIndex: controller.selectedIndex.value,

          onTap: controller.changeTab,

          type: BottomNavigationBarType.fixed,

          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey,

          items: const [

            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: 'About',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  // ================= HOME PAGE =================

  Widget buildHomePage() {

    return Obx(() {

      final user = controller.currentUser.value;

      return buildPage(
        Icons.home,
        'Welcome, ${user?.name ?? "User"}!',
        'You have successfully logged in.',
      );

    });
  }

  // ================= PROFILE PAGE =================

  Widget buildProfilePage() {

    return Obx(() {

      final isLoading = controller.isLoading.value;
      final user = controller.currentUser.value;

      if (user == null) {

        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text('Unable to load profile'),

              const SizedBox(height: 15),

              ElevatedButton(
                onPressed: controller.getProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(

        padding: const EdgeInsets.all(25),

        child: Form(

          key: controller.profileFormKey,

          child: Column(

            children: [

              // Profile Icon
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'View and update your personal information',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 30),

              // Full Name
              buildProfileField(
                label: 'Full Name',
                icon: Icons.person,
                textController: controller.nameController,
                enabled: !isLoading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // Username
              buildProfileField(
                label: 'Username',
                icon: Icons.account_circle,
                textController: controller.usernameController,
                enabled: !isLoading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // Email
              buildProfileField(
                label: 'Email Address',
                icon: Icons.email,
                textController: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading,
                validator: (value) {

                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }

                  if (!GetUtils.isEmail(value.trim())) {
                    return 'Please enter a valid email';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              // Mobile Number
              buildProfileField(
                label: 'Mobile Number',
                icon: Icons.phone,
                textController: controller.phoneController,
                keyboardType: TextInputType.phone,
                enabled: !isLoading,
                validator: (value) {

                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your mobile number';
                  }

                  if (!RegExp(r'^[0-9]{10}$')
                      .hasMatch(value.trim())) {
                    return 'Enter a valid 10-digit number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              // ================= UPDATE BUTTON =================

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(

                  onPressed: isLoading
                      ? null
                      : controller.updateProfile,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 15),

              // ================= DELETE ACCOUNT BUTTON =================

              SizedBox(
                width: double.infinity,
                height: 52,

                child: OutlinedButton.icon(

                  onPressed: isLoading
                      ? null
                      : controller.deleteAccount,

                  icon: const Icon(Icons.delete_outline),

                  label: const Text(
                    'Delete Account',
                    style: TextStyle(fontSize: 16),
                  ),

                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,

                    side: const BorderSide(
                      color: Colors.red,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

            ],
          ),
        ),
      );
    });
  }

  // ================= REUSABLE PROFILE TEXT FIELD =================

  Widget buildProfileField({

    required String label,
    required IconData icon,
    required TextEditingController textController,

    TextInputType keyboardType = TextInputType.text,

    bool enabled = true,

    String? Function(String?)? validator,

  }) {

    return TextFormField(

      controller: textController,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,

      decoration: InputDecoration(

        labelText: label,

        prefixIcon: Icon(
          icon,
          color: AppColors.primary,
        ),

        filled: true,
        fillColor: AppColors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ================= REUSABLE PAGE WIDGET =================

  Widget buildPage(
    IconData icon,
    String title,
    String description,
  ) {

    return Center(

      child: SingleChildScrollView(

        padding: const EdgeInsets.all(25),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              icon,
              size: 100,
              color: AppColors.primary,
            ),

            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              description,
              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 16,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}