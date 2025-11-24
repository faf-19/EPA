import 'dart:ui';

import 'package:get/get.dart';

class SignUpController extends GetxController {
  //TODO: Implement SignupController
  final fullName = ''.obs;
  final phoneNumber = ''.obs;
  final password = ''.obs;

  final _client = GetConnect();
  
  String? validateInputs(){
    if(fullName.value.trim().isEmpty){
      return "Full name is required";
    }
    if(phoneNumber.value.trim().isEmpty){
      return "Phone number is required";
    }
    if (password.value.length < 6) {
      return "Password must be at least 6 characters long";
    }
    return null;
  }

  Future<void> signUp() async {
    final validationError = validateInputs();

    if(validationError != null){
      Get.snackbar('Error', validationError,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFCDD2),
          colorText: const Color(0xFFB00020));
      return;
    }

    try {
      
    } catch (e) {
      
    }
  }
}
