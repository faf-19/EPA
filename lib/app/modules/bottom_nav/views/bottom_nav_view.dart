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

  // default unselected color (muted blue) and selected color (orange)
  static const Color _unselectedColor = Color(0xFF9DB2CE);
  static const Color _selectedColor = Color(0xFF1EA04A);

  Widget _buildNavItem(IconData icon, String label, int index, {Color? color}) {
    return Obx(() {
      final isSelected = controller.currentIndex.value == index;
      return Flexible(
        fit: FlexFit.tight,
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
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isSelected ? _selectedColor : (color ?? _unselectedColor), size: 24),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? _selectedColor : (color ?? _unselectedColor),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFabSlot() {
    return SizedBox(
      width: 64,
      child: Center(
        child: GestureDetector(
          onTap: () {
            // Navigate to report issue page
            Get.toNamed(Routes.REPORT_ISSUE);
          },
          child: Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: const Color(0xFF1EA04A),
              // shape: BoxShape.square,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8A5CFF).withOpacity(0.55),
                  spreadRadius: 6,
                  blurRadius: 26,
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
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
      height: 88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(Icons.home_outlined, "Home", 0, color: _unselectedColor),
                _buildNavItem(Icons.map_outlined, "Office", 1, color: _unselectedColor),
                // center FAB slot
                _buildFabSlot(),
                _buildNavItem(Icons.monitor_heart_outlined, "Status", 2, color: _unselectedColor),
                _buildNavItem(Icons.person_outline, "Profile", 3, color: _unselectedColor),
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
