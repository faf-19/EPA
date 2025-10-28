import 'package:eprs/app/modules/bottom_nav/views/bottom_nav_view.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/report_controller.dart';

class ReportView extends GetView<ReportController> {
  const ReportView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Report',
        subtitle: 'Help improve your community',
        showBack: true,
      ),
      body: const Center(
        child: Text(
          'ReportView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),

      bottomNavigationBar: BottomNavBar(),
    );
  }
}
