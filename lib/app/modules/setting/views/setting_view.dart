import 'package:eprs/app/modules/bottom_nav/views/bottom_nav_view.dart';
import 'package:eprs/app/modules/faq/views/faq_view.dart';
import 'package:eprs/app/modules/setting/views/privacy_policy_view.dart';
import 'package:eprs/app/modules/term_and_conditions/views/term_and_conditions_view.dart';
import '../../language/views/language_view.dart';
import '../../../widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/setting_controller.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});


  Widget _buildOptionTile(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, indent: 0, endIndent: 0);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Setting', subtitle: 'Help improve your community'),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F6F4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.info_outline, color: Color(0xFF1EA04A)),
                  ),
                  title: const Text('Guest', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: open profile or login
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Options list (use Flexible + shrinkWrap so card doesn't expand when content is short)
              Flexible(
                fit: FlexFit.loose,
                child: Material(
                  color: Colors.white,
                  elevation: 2,
                  borderRadius: BorderRadius.circular(12),
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildOptionTile('App Language', () { Get.to(const LanguageView()); }),
                      _buildDivider(),
                      _buildOptionTile('Frequently Asked Questions', () { Get.to(const FaqView()); }),
                      _buildDivider(),
                      _buildOptionTile('Contact Us', () {}),
                      _buildDivider(),
                      _buildOptionTile('Privacy Policy', () { Get.to(const PrivacyPolicyView()); }),
                      _buildDivider(),
                      _buildOptionTile('Term and Conditions', () { Get.to(const TermAndConditionsView()); }),
                      _buildDivider(),
                      _buildOptionTile('About EPA v1.1', () {}),
                      _buildDivider(),
                      _buildOptionTile('Rate Us', () {}),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
