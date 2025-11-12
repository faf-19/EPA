import 'package:eprs/app/modules/awareness/views/awareness_view.dart';
import 'package:eprs/app/modules/bottom_nav/widgets/bottom_nav_footer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bottom_nav_controller.dart';
import '../../home/views/home_view.dart';
import '../../office/views/office_view.dart';
import '../../status/views/status_view.dart';
import '../../setting/views/setting_view.dart';
// Import bindings so we can register controllers when the shell is created
import '../../home/bindings/home_binding.dart';
import '../../office/bindings/office_binding.dart';
import '../../awareness/bindings/awareness_binding.dart';
import '../../status/bindings/status_binding.dart';
import '../../setting/bindings/setting_binding.dart';

class BottomNavBar extends StatefulWidget {
  BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late final BottomNavController controller;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<BottomNavController>()) {
      controller = Get.find<BottomNavController>();
    } else {
      // Register the BottomNavController permanently
      controller = Get.put(
        BottomNavController(),
        permanent: true,
      );

      // Ensure page-level controllers are registered before pages build.
      // This mirrors what route-level bindings would normally do when
      // navigating to each page. Registering here avoids "Controller not found"
      // errors when the shell instantiates pages directly.
      HomeBinding().dependencies();
      OfficeBinding().dependencies();
      AwarenessBinding().dependencies();
      StatusBinding().dependencies();
      SettingBinding().dependencies();
    }
  }

  // Pages are created normally; controllers for these pages are registered
  // in initState via their bindings so the pages can safely call Get.find().
  final List<Widget> _pages = const [
    HomeView(),
    OfficeView(),
    AwarenessView(),
    StatusView(),
    SettingView(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await controller.onWillPop();
        if (shouldPop) {
          Get.back(result: result);
        }
      },
      child: Obx(() => Scaffold(
            body: IndexedStack(
              index: controller.currentIndex.value,
              children: _pages,
            ),
          bottomNavigationBar: const BottomNavBarFooter(),
        ),
      ),
    );
  }
}
