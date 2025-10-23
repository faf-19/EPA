import 'package:get/get.dart';

import '../controllers/office_controller.dart';

class OfficeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OfficeController>(
      () => OfficeController(),
    );
  }
}
