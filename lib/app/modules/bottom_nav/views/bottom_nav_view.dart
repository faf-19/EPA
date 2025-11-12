import 'package:eprs/app/modules/awareness/views/awareness_view.dart';
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

  static const Color _activeColor = Color(0xFF1EA04A);
  static const Color _inactiveColor = Colors.white70;

  final List<_NavItemData> _items = const [
    _NavItemData(icon: Icons.home_outlined, label: "Home"),
    _NavItemData(icon: Icons.map_outlined, label: "Office"),
    _NavItemData(icon: Icons.people_outline, label: "Community"),
    _NavItemData(icon: Icons.monitor_heart_outlined, label: "Status"),
    _NavItemData(icon: Icons.person_outline, label: "Profile"),
  ];

  // Pages are created normally; controllers for these pages are registered
  // in initState via their bindings so the pages can safely call Get.find().
  final List<Widget> _pages = const [
    HomeView(),
    OfficeView(),
    AwarenessView(),
    StatusView(),
    SettingView(),
  ];

  Widget _buildNavItem(BuildContext context, int index) {
    final data = _items[index];

    return Obx(() {
      final isSelected = controller.currentIndex.value == index;

      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => controller.changePage(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  data.icon,
                  color: isSelected ? _activeColor : _inactiveColor,
                  size: isSelected ? 22 : 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white : _inactiveColor,
                  fontSize: 11.5,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const double navBarHeight = 70;

    return WillPopScope(
      onWillPop: controller.onWillPop,
      child: Obx(() => Scaffold(
            body: IndexedStack(
              index: controller.currentIndex.value,
              children: _pages,
            ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              height: navBarHeight,
              decoration: const BoxDecoration(
                color: _activeColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  _items.length,
                  (index) => Expanded(
                    child: _buildNavItem(context, index),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.label,
  });
}
