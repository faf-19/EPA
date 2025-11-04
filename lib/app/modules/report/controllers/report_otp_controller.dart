import 'dart:async';
import 'package:get/get.dart';
import 'package:eprs/app/routes/app_pages.dart';

class ReportOtpController extends GetxController {
  var code = ''.obs;
  var seconds = 60.obs;
  var showKeypad = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startTimer() {
    _timer?.cancel();
    seconds.value = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds.value <= 0) {
        t.cancel();
        update();
      } else {
        seconds.value--;
      }
    });
  }

  void append(String d) {
    if (code.value.length >= 4) return;
    code.value += d;
  }

  void backspace() {
    if (code.value.isEmpty) return;
    code.value = code.value.substring(0, code.value.length - 1);
  }

  void confirm() {
    if (code.value.length < 4) return;
    final fakeId = 'REP-${DateTime.now().millisecondsSinceEpoch}';
    Get.toNamed(Routes.Report_Success, arguments: fakeId);
  }

  void toggleKeypad(bool visible) {
    showKeypad.value = visible;
  }
}
