import 'package:get/get.dart';

class SignUpController extends GetxController {
  //TODO: Implement SignupController
  final fullName = ''.obs;
  final phoneNumber = ''.obs;
  final password = ''.obs;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
