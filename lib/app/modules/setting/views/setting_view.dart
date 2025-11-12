import 'package:eprs/app/modules/about/views/about_view.dart';
// Bottom nav is provided by the app shell; don't import it here to avoid recursion.
import 'package:eprs/app/modules/contact_us/views/contact_us_view.dart';
import 'package:eprs/app/modules/faq/views/faq_view.dart';
import 'package:eprs/app/modules/setting/views/privacy_policy_view.dart';
import 'package:eprs/app/modules/term_and_conditions/views/term_and_conditions_view.dart';
import '../../language/views/language_view.dart';
import '../../../widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/setting_controller.dart';
import 'package:eprs/app/routes/app_pages.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  // ── Helper for option tiles ────────────────────────────────────────────────
  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F6F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF1EA04A)),
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

  // ── Build UI ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(
          title: 'Setting',
          subtitle: 'Help improve your community',
        ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // User header card
              Material(
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
                      color: const Color(0xFFF1F6F4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child:
                        const Icon(Icons.person_outline, color: Color(0xFF1EA04A)),
                  ),
                  title: const Text('Guest',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: open profile or login
                  },
                ),
              ),

              const SizedBox(height: 16),

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
                      _buildOptionTile(Icons.language, 'App Language',
                          () => Get.to(const LanguageView())),
                      _buildDivider(),
                      _buildOptionTile(Icons.help_outline,
                          'Frequently Asked Questions', () => Get.to(const FaqView())),
                      _buildDivider(),
                      _buildOptionTile(Icons.contact_support_outlined, 'Contact Us',
                          () => Get.to(const ContactUsView())),
                      _buildDivider(),
                      _buildOptionTile(Icons.privacy_tip_outlined, 'Privacy Policy',
                          () => Get.to(const PrivacyPolicyView())),
                      _buildDivider(),
                      _buildOptionTile(Icons.description_outlined,
                          'Term and Conditions', () => Get.to(const TermAndConditionsView())),
                      _buildDivider(),
                      _buildOptionTile(Icons.info_outline, 'About EPA v1.1',
                          () => Get.to(const AboutView())),
                      _buildDivider(),
                      _buildOptionTile(Icons.star_rate_outlined, 'Rate Us', () {}),
                      _buildDivider(),
                      _buildOptionTile(Icons.logout, "Logout", () {})
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      // BottomNavBar is provided by the top-level shell; remove 
    );
  }
}
