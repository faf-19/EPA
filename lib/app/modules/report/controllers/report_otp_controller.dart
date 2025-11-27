import 'dart:async';
import 'package:get/get.dart';

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
    // Generated id is stored for potential later use; navigation is handled
    // by the view so it uses the local nested Navigator and keeps the
    // app shell visible.
    // Keep this method side-effect free for navigation responsibilities.
    // Store the generated id for testing/debugging if needed.
    // (No navigation here.)
    // ignore: unused_local_variable
    final _ = fakeId;
  }

  void toggleKeypad(bool visible) {
    showKeypad.value = visible;
  }
}
