import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingController extends GetxController {
  final count = 0.obs;
  
  // User data
  var userName = ''.obs;
  var phoneNumber = ''.obs;
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    final storage = Get.find<GetStorage>();
    final token = storage.read('auth_token');
    
    isLoggedIn.value = token != null && token.toString().isNotEmpty;
    
    if (isLoggedIn.value) {
      userName.value = storage.read('username') ?? 
                       storage.read('full_name') ?? 
                       'User';
      phoneNumber.value = storage.read('phone') ?? 
                          storage.read('phone_number') ?? 
                          '';
    }
  }

  void refreshUserData() {
    _loadUserData();
  }

  void increment() => count.value++;
}
