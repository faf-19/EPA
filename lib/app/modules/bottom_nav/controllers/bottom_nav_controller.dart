import 'package:get/get.dart';

class BottomNavController extends GetxController {
  RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  late final String username;
  late final String phone;

  @override
  void onInit() {
    final args = Get.arguments as Map<String, String>?;
    username = args?['username'] ?? 'Guest';
    phone = args?['phone'] ?? '';
    super.onInit();
  }
}
