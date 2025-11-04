// lib/modules/bottom_nav/views/bottom_nav_widget.dart
import 'package:eprs/app/modules/home/views/home_view.dart';
import 'package:eprs/app/modules/office/views/office_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bottom_nav_controller.dart';
import '../../../routes/app_pages.dart';
//import '../../office/views/office_view.dart';

class BottomNavBar extends StatelessWidget {
  // If controller hasn't been registered (navigated directly), create it here so Get.find doesn't throw.
  final BottomNavController controller = Get.isRegistered<BottomNavController>()
      ? Get.find<BottomNavController>()
      : Get.put<BottomNavController>(BottomNavController());

  BottomNavBar({super.key});

  // default unselected color and selected color
  static const Color _unselectedColor = Color(0xFF9DB2CE);
  static const Color _selectedColor = Color(0xFF1EA04A);
  static const Color _backgroundColor = Colors.white;
  static const Color _fabColor = Color(0xFF1EA04A);

  Widget _buildNavItem(IconData icon, String label, int index, {Color? color}) {
    return Obx(() {
      final isSelected = controller.currentIndex.value == index;
      return Flexible(
        fit: FlexFit.tight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // handle special routes first (do not change controller index before routing)
              if (index == 0){
                Get.toNamed(Routes.HOME);
              }
              if (index == 3) {
                // Profile -> Settings
                Get.toNamed(Routes.SETTING);
              }
              else if (index == 1) {
                // Office page - navigate directly to view to avoid named-route lookup issues
                Get.to(() => const OfficeView());
              }
              else if (index == 2) {
                // Status page
                Get.toNamed(Routes.STATUS);
              }

              // default: update controller's current index (switch within bottom navigation)
              controller.changePage(index);
              return;
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? _selectedColor.withOpacity(0.1) : Colors.transparent,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(isSelected ? 8 : 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? _selectedColor.withOpacity(0.15) : Colors.transparent,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? _selectedColor : (color ?? _unselectedColor),
                      size: isSelected ? 28 : 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isSelected ? _selectedColor : (color ?? _unselectedColor),
                      fontSize: isSelected ? 13 : 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFabSlot() {
    return SizedBox(
      width: 72,
      child: Center(
        child: GestureDetector(
          onTap: () {
            // TODO: handle FAB tap
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_fabColor, _fabColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _fabColor.withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: _fabColor.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.report_problem,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build the inner bar content as a reusable widget so we can render it
    // either inside a BottomAppBar (when a Scaffold ancestor exists) or
    // as a plain Container (when the widget is used without a Scaffold).
    Widget barContent = Container(
      height: 90,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(Icons.home_outlined, "Home", 0, color: _unselectedColor),
                _buildNavItem(Icons.map_outlined, "Office", 1, color: _unselectedColor),
                // center FAB slot
                _buildFabSlot(),
                _buildNavItem(Icons.monitor_heart_outlined, "Status", 2, color: _unselectedColor),
                _buildNavItem(Icons.person_outline, "Settings", 3, color: _unselectedColor),
              ],
            ),
          ),
        ],
      ),
    );

    // If there is a Scaffold ancestor, return a BottomAppBar to integrate
    // properly with Scaffold (notch, geometry, etc.). If not, return a
    // plain Container so the widget can be used standalone without throwing.
    final hasScaffold = context.findAncestorWidgetOfExactType<Scaffold>() != null;
    if (hasScaffold) {
      return BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: barContent,
      );
    }

    // No Scaffold ancestor — render a safe fallback (non-throwing) bar.
    return Material(
      elevation: 4,
      child: barContent,
    );
  }
}
