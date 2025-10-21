import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/splash_controller.dart';
import '../../bottom_nav/views/bottom_nav_view.dart';
import '../../bottom_nav/controllers/bottom_nav_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    // ensure BottomNavController is available for BottomNavBar
    if (!Get.isRegistered<BottomNavController>()) {
      Get.put(BottomNavController());
    }
    return Scaffold(
      extendBody: true,
      body: const Center(
        child: Image(image: AssetImage('assets/logo.png')),
      ),
      
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
