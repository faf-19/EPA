import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/bottom_nav/controllers/bottom_nav_controller.dart';
import '../modules/bottom_nav/views/bottom_nav_view.dart';
import '../modules/home/views/home_view.dart';

class BottomNavWrapper extends GetView<BottomNavController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: [
            //OfficeView(), // index 0
            HomeView(), // index 1
            // StatusView(), // index 2
            // ProfileView(),// index 3
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
