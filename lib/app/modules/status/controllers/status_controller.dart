import 'package:get/get.dart';

class StatusController extends GetxController {
  //TODO: Implement StatusController

  final count = 0.obs;
  var selectedFilter = 'All'.obs;


  void increment() => count.value++;

  void setFilter(String filter){
    selectedFilter.value = filter;
  }
}
