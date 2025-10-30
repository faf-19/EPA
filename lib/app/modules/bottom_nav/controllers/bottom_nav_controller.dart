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
}
