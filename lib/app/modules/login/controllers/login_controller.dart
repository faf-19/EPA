import 'package:eprs/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LoginController extends GetxController {
  var userName = ''.obs;
  var phoneNumber = ''.obs;

  void submitLogin() {
    final phone = phoneNumber.value.trim();
    final username = userName.value.trim();

    // Basic phone number validation (Ethiopian format: starts with 09 and has 10 digits)
    final isValidPhone = RegExp(r'^09\d{8}$').hasMatch(phone);

    if (!isValidPhone) {
      Get.defaultDialog(
        title: '',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        backgroundColor: Colors.white,
        radius: 12,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ Invalid Input',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please enter a valid Ethiopian phone number (e.g. 0912345678)',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      return;
    }

    if (username.isEmpty) {
      Get.defaultDialog(
        title: '👤 Missing Username',
        middleText: 'Please enter your username to continue',
        confirm: ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('OK', style: TextStyle(color: Colors.white)),
        ),
      );
      return;
    }

    // ✅ Proceed to next screen
    Get.offNamed(
      Routes.HOME,
      arguments: {'username': username, 'phone': phone},
    );
  }
}
