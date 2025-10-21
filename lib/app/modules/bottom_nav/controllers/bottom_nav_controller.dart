import 'package:get/get.dart';

class BottomNavController extends GetxController {
  //TODO: Implement BottomNavController

  final currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}
