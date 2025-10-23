import 'package:get/get.dart';

import '../controllers/awareness_controller.dart';

class AwarenessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AwarenessController>(
      () => AwarenessController(),
    );
  }
}
