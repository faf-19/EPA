import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import 'package:flutter/material.dart';
import '../../bottom_nav/views/bottom_nav_view.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 2), () {
      Get.offNamed(Routes.LOGIN);
    });
  }
}
