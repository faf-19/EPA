import 'package:eprs/core/theme/app_colors.dart';
import 'package:eprs/core/theme/app_fonts.dart';
import '../../../widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../bottom_nav/controllers/bottom_nav_controller.dart';
import '../controllers/setting_controller.dart';
import 'package:eprs/app/routes/app_pages.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  // ── Helper for option tiles ────────────────────────────────────────────────
  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.onPrimary,
          // borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16);
  }

  // Build user profile section (when logged in)
  Widget _buildUserProfileSection() {
    return Column(
      children: [
        // Profile picture
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              controller.userName.value.isNotEmpty
                  ? controller.userName.value[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // User name
        Obx(() => Text(
          controller.userName.value,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        )),
        const SizedBox(height: 6),
        
        // Phone number
        Obx(() => Text(
          controller.phoneNumber.value.isNotEmpty 
              ? controller.phoneNumber.value 
              : 'No phone number',
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 13,
            color: Colors.grey[600],
          ),
        )),
        const SizedBox(height: 16),
        
        // Edit profile button
        OutlinedButton(
          onPressed: () {
            // TODO: Navigate to edit profile page
            // Get.snackbar(
            //   'Edit Profile',
            //   'Edit profile feature coming soon',
            //   snackPosition: SnackPosition.BOTTOM,
            // );
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'edit_profile',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build guest card (when not logged in)
  Widget _buildGuestCard() {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.onPrimary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.person_outline, color: Colors.black),
        ),
        title: const Text('Guest',
            style: TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to login
          Get.toNamed(Routes.LOGIN);
        },
      ),
    );
  }

  // ── Build UI ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Refresh user data when view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshUserData();
    });

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: 'Settings',
          showBack: true,
          forceHomeOnBack: true, // ensure back always returns to home shell
        ),

      body: SafeArea(
        child:
        //  Padding(
        //   // padding: const EdgeInsets.symmetric(horizontal: 10.0),
        //   child: 
          Column(
            children: [
              const SizedBox(height: 16),
              // User profile section (only if logged in)
              Obx(() {
                if (controller.isLoggedIn.value) {
                  return _buildUserProfileSection();
                } else {
                  return _buildGuestCard();
                }
              }),

              const SizedBox(height: 20),

              // Options list
              Flexible(
                fit: FlexFit.loose,
                child: Material(
                  color: Colors.white,
                  // elevation: 2,
                  borderRadius: BorderRadius.circular(12),
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildOptionTile(Icons.language, 'Language',
                          () => Get.toNamed(Routes.LANGUAGE)),
                      _buildDivider(),
                      _buildOptionTile(Icons.help_outline,
                          'FAQ', () => Get.toNamed(Routes.FAQ)),
                      _buildDivider(),
                      _buildOptionTile(Icons.local_post_office, 'Office',
                          () => Get.toNamed(Routes.OFFICE)),
                      _buildDivider(),
                      _buildOptionTile(Icons.privacy_tip_outlined, 'Privacy Policy',
                          () => Get.toNamed(Routes.Privacy_Policy)),
                      _buildDivider(),
                      _buildOptionTile(Icons.description_outlined,
                          'Term and Conditions', () => Get.toNamed(Routes.TERM_AND_CONDITIONS)),
                      _buildDivider(),
                      _buildOptionTile(Icons.info_outline, 'About EPA App',
                          () => Get.toNamed(Routes.ABOUT)),
                      _buildDivider(),
                      _buildOptionTile(Icons.star_rate_outlined, 'Rate Us', () {}),
                      _buildDivider(),
                      _buildOptionTile(Icons.logout, "Logout", () {
                        // Confirm logout
                        Get.defaultDialog(
                          title: '',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          backgroundColor: Colors.white,
                          radius: 12,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Are you sure you want to logout?',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Get.back(),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: AppColors.primary),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        // Reset bottom nav to home tab if controller exists
                                        if (Get.isRegistered<BottomNavController>()) {
                                          try {
                                            final navCtrl = Get.find<BottomNavController>();
                                            navCtrl.resetToHome();
                                          } catch (_) {}
                                        }

                                        // Clear stored data and navigate to splash/login
                                        final box = Get.find<GetStorage>();
                                        await box.erase();

                                        // After clearing storage, navigate to splash screen
                                        Get.offAllNamed(Routes.SPLASH);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Yes',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      })
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        // ),
      ),
      // BottomNavBar is provided by the top-level shell; remove 
    );
  }
}
