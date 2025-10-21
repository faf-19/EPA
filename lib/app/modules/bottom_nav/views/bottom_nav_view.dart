// lib/modules/bottom_nav/views/bottom_nav_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bottom_nav_controller.dart';

class BottomNavBar extends StatelessWidget {
  final BottomNavController controller = Get.find<BottomNavController>();

  BottomNavBar({Key? key}) : super(key: key);

  // default unselected color (muted blue) and selected color (orange)
  static const Color _unselectedColor = Color(0xFF9DB2CE);
  static const Color _selectedColor = Color(0xFF1EA04A);

  Widget _buildNavItem(IconData icon, String label, int index, {Color? color}) {
    return Obx(() {
      final isSelected = controller.currentIndex.value == index;
      return Flexible(
        fit: FlexFit.tight,
        child: InkWell(
          onTap: () => controller.changePage(index),
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
            // TODO: handle FAB tap
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
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: Container(
        height: 88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
            // bottomLeft: Radius.circular(20),
            // bottomRight: Radius.circular(20),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // purple glow behind center FAB (positioned above the bar)
            // Positioned(
            //   top: -28,
            //   left: 0,
            //   right: 0,
            //   child: Center(
            //     child: Container(
            //       width: 72,
            //       height: 72,
            //       decoration: BoxDecoration(
            //         color: const Color(0xFF1EA04A), // green base for the FAB glow layering
            //         shape: BoxShape.circle,
            //         boxShadow: [
            //           BoxShadow(
            //             color: const Color(0xFF8A5CFF).withOpacity(0.55),
            //             spreadRadius: 8,
            //             blurRadius: 26,
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            // row of items with space for FAB
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
      ),
    );
  }
}
