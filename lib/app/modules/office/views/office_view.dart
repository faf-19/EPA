import 'package:eprs/app/modules/bottom_nav/views/bottom_nav_view.dart';
import 'package:eprs/app/routes/app_pages.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/office_controller.dart';

class OfficeView extends GetView<OfficeController> {
  const OfficeView({super.key});

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
      appBar: const CustomAppBar(title: 'Offices', subtitle: 'Help improve your community'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // User header card
              

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
                      _buildOptionTile('Addis Ketema', () {
                        // navigate using named route and pass the office name as argument
                        Get.toNamed(Routes.OFFICE_DETAIL_MAP_VIEW, arguments: 'Addis Ketema');
                      }),
                      _buildDivider(),
                      _buildOptionTile('Kolfe Keraniyo', () => {}),
                      _buildDivider(),
                      _buildOptionTile('Bole', () {}),
                      _buildDivider(),
                      _buildOptionTile('Lideta', () {}),
                      _buildDivider(),
                      _buildOptionTile('Arada', () {}),
                      _buildDivider(),
                      _buildOptionTile('Yeka', () {}),
                      _buildDivider(),
                      _buildOptionTile('Lemi Kura', () => {}),
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