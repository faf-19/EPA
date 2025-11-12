import 'package:get/get.dart';
import 'package:eprs/app/routes/app_pages.dart';

class BottomNavController extends GetxController {
  RxInt currentIndex = 0.obs;

  void changePage(int index) {
    if (Get.currentRoute != Routes.HOME) {
      Get.until((route) {
        final name = route.settings.name;
        return name == Routes.HOME || route.isFirst;
      });
    }
    currentIndex.value = index;
  }

  late final String username;
  late final String phone;

  @override
  void onInit() {
    final arg = Get.arguments;
    if (arg is Map<String, String>) {
      username = arg['username'] ?? 'Guest';
      phone = arg['phone'] ?? '';
    } else {
      username = 'Guest';
      phone = '';
    }
    super.onInit();
  }

  void resetToHome() {
    currentIndex.value = 0;
  }

  Future<bool> onWillPop() async {
    // Always navigate to home if not already there
    if (currentIndex.value != 0) {
      resetToHome(); // Go back to Home tab
      return false; // Prevent default back behavior (don't exit app)
    }
    // Only allow exit if already on Home page
    return true; // Exit app if already on Home
  }

  void changeTabIndex(int index) => changePage(index);
}
