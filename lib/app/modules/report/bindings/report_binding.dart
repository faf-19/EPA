import 'package:get/get.dart';

import '../controllers/report_controller.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    // Use put instead of lazyPut to ensure controller is created fresh each time
    // This helps avoid type issues with hot reload
    Get.put<ReportController>(
      ReportController(),
      permanent: false,
    );
  }
}
