import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/bottom_nav_controller.dart';
import '../../office/views/office_view.dart';

class BottomNavBar extends StatelessWidget {
  BottomNavBar({super.key});

  final BottomNavController controller = Get.put(
    BottomNavController(),
    permanent: true,
  );

  static const Color _activeColor = Color(0xFF1EA04A);
  static const Color _inactiveColor = Colors.white70;

  // ✅ Single source of tab configuration (scalable for big apps)
  final List<_NavItemData> _items = const [
    _NavItemData(icon: Icons.home_outlined, label: "Home", route: Routes.HOME),
    _NavItemData(icon: Icons.map_outlined, label: "Office", route: Routes.OFFICE),
    _NavItemData(icon: Icons.people_outline, label: "Community", route: Routes.AWARENESS),
    _NavItemData(icon: Icons.monitor_heart_outlined, label: "Status", route: Routes.STATUS),
    _NavItemData(icon: Icons.person_outline, label: "Profile", route: Routes.SETTING),
  ];

  Widget _buildNavItem(BuildContext context, int index) {
    final data = _items[index];

    return Obx(() {
      final isSelected = controller.currentIndex.value == index;

      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          controller.changePage(index);

          // Routing logic — use offAllNamed for main tab pages
          switch (data.route) {
            case Routes.HOME:
              Get.offAllNamed(Routes.HOME);
              break;
            case Routes.OFFICE:
              Get.to(() => const OfficeView());
              break;
            default:
              Get.toNamed(data.route);
          }
        },
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
    final media = MediaQuery.of(context);
    final double bottomInset = media.padding.bottom;
    final double navBarHeight = 70 + bottomInset;

    return SafeArea(
      top: false,
      child: Container(
        height: navBarHeight,
        decoration: const BoxDecoration(
          color: _activeColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(22),
            bottomRight: Radius.circular(22),
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
    );
  }
}

// Data model for cleaner scaling
class _NavItemData {
  final IconData icon;
  final String label;
  final String route;

  const _NavItemData({
    required this.icon,
    required this.label,
    required this.route,
  });
}
