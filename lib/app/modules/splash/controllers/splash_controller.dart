import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    // Schedule navigation after the first frame to avoid navigator locked errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        Get.offNamed(Routes.LOGIN);
      });
    });
  }
}
