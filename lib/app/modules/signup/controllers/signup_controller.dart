import 'package:get/get.dart';
import 'package:eprs/app/routes/app_pages.dart';
import 'package:get_storage/get_storage.dart';

class SignupController extends GetxController {
  final userName = ''.obs;
  final phone = ''.obs;
  final password = ''.obs;

  final _storage = GetStorage();

  void register() {
    final name = userName.value.trim();
    final p = phone.value.trim();
    final pass = password.value;
    if (name.isEmpty || p.isEmpty || pass.isEmpty) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }

    // TODO: perform real signup request. For now simulate success.
    final token = 'token_${DateTime.now().millisecondsSinceEpoch}';
    _storage.write('token', token);
    _storage.write('username', name);
    _storage.write('phone', p);

    // Navigate to home
    Get.offNamed(Routes.HOME, arguments: {'username': name, 'phone': p});
  }
}
